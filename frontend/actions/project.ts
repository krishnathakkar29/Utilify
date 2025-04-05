"use server";

import prisma from "@/lib/db";
import { pollRepo } from "@/lib/github";
import { currentUser } from "@clerk/nextjs/server";

interface ActionResponse {
  success: boolean;
  message: string;
  data?: any;
}

export async function createProject(
  repoUrl: string,
  projectName: string
): Promise<ActionResponse> {
  try {
    const user = await currentUser();
    if (!user) {
      return { success: false, message: "Unauthorized" };
    }

    const userDB = await prisma.user.findUnique({
      where: {
        clerkUserId: user.id,
      },
    });

    if (!userDB) {
      return { success: false, message: "User not found" };
    }

    const project = await prisma.project.create({
      data: {
        name: projectName,
        githubUrl: repoUrl,
        userToProjects: {
          create: {
            userId: userDB.id,
          },
        },
      },
    });

    await pollRepo(repoUrl, project.id);

    return {
      success: true,
      message: "Project created successfully",
      data: project,
    };
  } catch (error) {
    console.error("Error creating project:", error);
    return {
      success: false,
      message: error instanceof Error ? error.message : "Internal Server Error",
    };
  }
}

export async function getUserProjects(): Promise<ActionResponse> {
  try {
    const user = await currentUser();
    if (!user) {
      return { success: false, message: "Unauthorized" };
    }

    const userDB = await prisma.user.findUnique({
      where: {
        clerkUserId: user.id,
      },
    });

    if (!userDB) {
      return { success: false, message: "User not found" };
    }

    const projects = await prisma.userToProject.findMany({
      where: {
        userId: userDB.id,
      },
      include: {
        project: true,
      },
    });

    return {
      success: true,
      message: "Projects fetched successfully",
      data: projects,
    };
  } catch (error) {
    console.error("Error fetching user projects:", error);
    return {
      success: false,
      message: error instanceof Error ? error.message : "Internal Server Error",
    };
  }
}

export async function getCommitByProjectId(projectId: string) {
  try {
    const commits = await prisma.commit.findMany({
      where: {
        projectId: projectId,
      },
    });
    return commits;
  } catch (error) {
    console.error("Error fetching commits:", error);
    throw new Error("Failed to fetch commits");
  }
}
