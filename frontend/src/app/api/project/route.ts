import prisma from "@/lib/db";
import { currentUser } from "@clerk/nextjs/server";

export async function POST(req: Request) {
  try {
    const user = await currentUser();

    if (!user) {
      return new Response("Unauthorized", { status: 401 });
    }

    const userDB = await prisma.user.findUnique({
      where: {
        clerkUserId: user.id,
      },
    });

    if (!userDB) {
      return new Response("User not found", { status: 404 });
    }
    const { repoUrl, projectName } = await req.json();

    const project = await prisma.project.create({
      data: {
        name: projectName,
        githubUrl: repoUrl,
      },
    });

    // Then create the relationship
    await prisma.userToProject.create({
      data: {
        userId: userDB.id,
        projectId: project.id,
      },
    });
  } catch (error) {}
}
