"use client";
import * as React from "react";

import {
  Sidebar,
  SidebarContent,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarRail,
} from "@/components/ui/sidebar";
import Link from "next/link";
import axios from "axios";
import { getUserProjects } from "../../actions/project";
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from "./ui/collapsible";
import { ChevronRight } from "lucide-react";
import { Project } from "@prisma/client";
import { useProject } from "@/context/project-context";
import { useQuery } from "@tanstack/react-query";
import { cn } from "@/lib/utils";

const data = {
  versions: ["1.0.1"],
  navMain: [
    {
      title: "Overview",
      url: "/dashboard",
      items: [
        {
          title: "Dashboard",
          url: "/dashboard",
        },
      ],
    },
    {
      title: "DevTryyyy",
      url: "#",
      items: [
        {
          title: "Github",
          url: "/code/developer",
        },
        {
          title: "Current Project",
          url: "/code/developer/current-project",
        },
      ],
    },
    {
      title: "Documents",
      url: "#",
      items: [
        {
          title: "CSV & Excel Functions",
          url: "/dashboard",
        },
        {
          title: "File Hosting",
          url: "/dashboard",
        },
        {
          title: "Document Summarization",
          url: "/dashboard",
        },
        {
          title: "Query Document",
          url: "/dashboard",
        },
      ],
    },
    {
      title: "Work",
      url: "#",
      items: [
        {
          title: "Form Builder",
          url: "/dashboard",
        },
        {
          title: "Bulk Email Sender",
          url: "/dashboard",
        },
        {
          title: "QR Generator",
          url: "/dashboard",
        },
        {
          title: "Schedule Meetings",
          url: "/dashboard",
        },
      ],
    },
    {
      title: "Code And Conquer",
      url: "#",
      items: [
        {
          title: "Code Formatter",
          url: "/dashboard",
        },
        {
          title: "Web Compiler",
          url: "/dashboard",
        },
        {
          title: "JSON XML Validator",
          url: "/dashboard",
        },
        {
          title: "Api Tools",
          url: "/dashboard",
        },
        {
          title: "Markdown Editor",
          url: "/dashboard",
        },
      ],
    },
    {
      title: "Security & Network",
      url: "#",
      items: [
        {
          title: "Password Generator",
          url: "/dashboard",
        },
        {
          title: "Password Strength Checker",
          url: "/dashboard",
        },
        {
          title: "Random Number Generator",
          url: "/dashboard",
        },
        {
          title: "DNS / IP Lookup",
          url: "/dashboard",
        },
        {
          title: "AES Encryptor",
          url: "/dashboard",
        },
      ],
    },
    {
      title: "Everyday Tools",
      url: "#",
      items: [
        {
          title: "Unit Converter",
          url: "/dashboard",
        },
        {
          title: "Currency Converter",
          url: "/dashboard",
        },
        {
          title: "World Clock",
          url: "/dashboard",
        },
        {
          title: "Timer & Counter",
          url: "/dashboard",
        },
        {
          title: "Notes",
          url: "/dashboard",
        },
        {
          title: "Color Pallete Generator",
          url: "/dashboard",
        },
      ],
    },
  ],
};

interface ProjectData {
  project: Project;
  userId: string;
  projectId: string;
}

export function AppSidebar({ ...props }: React.ComponentProps<typeof Sidebar>) {
  const {
    data: projects,
    isLoading,
    error,
  } = useQuery<ProjectData[]>({
    queryKey: ["projects"],
    queryFn: async () => {
      const response = await getUserProjects();
      if (!response.success) {
        throw new Error(response.message);
      }
      return response.data;
    },
  });

  const { setCurrentProject, currentProject } = useProject();

  const handleProjectClick = (projectData: ProjectData) => {
    setCurrentProject(projectData.project);
  };

  console.log(currentProject);

  return (
    <Sidebar {...props}>
      <SidebarHeader>
        <Link href="/">
          <div className="flex gap-2 font-semibold text-lg items-end leading-none p-2">
            {/* <FramerLogoIcon className="size-6" /> */}
            {/* <img src="/logo.png" alt="Logo" className="h-6" /> */}
            Utilify
          </div>
        </Link>
      </SidebarHeader>
      <SidebarContent>
        {/* Projects Section */}
        <Collapsible key="projects" defaultOpen className="group/collapsible">
          <SidebarGroup>
            <SidebarGroupLabel
              asChild
              className="group/label text-sm text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground"
            >
              <CollapsibleTrigger>
                My Projects{" "}
                <ChevronRight className="ml-auto transition-transform group-data-[state=open]/collapsible:rotate-90" />
              </CollapsibleTrigger>
            </SidebarGroupLabel>
            <CollapsibleContent>
              <SidebarGroupContent>
                <SidebarMenu>
                  {isLoading ? (
                    <SidebarMenuItem>
                      <div className="text-sm text-muted-foreground">
                        Loading projects...
                      </div>
                    </SidebarMenuItem>
                  ) : error ? (
                    <SidebarMenuItem>
                      <div className="text-sm text-red-500">
                        Failed to load projects
                      </div>
                    </SidebarMenuItem>
                  ) : projects && projects.length > 0 ? (
                    projects.map((projectData) => (
                      <SidebarMenuItem key={projectData.projectId}>
                        <SidebarMenuButton
                          asChild
                          onClick={() => handleProjectClick(projectData)}
                          className={cn(
                            "w-full transition-colors",
                            currentProject?.id === projectData.project.id &&
                              "bg-primary/10 text-primary font-medium"
                          )}
                        >
                          <div className="flex items-center gap-2">
                            <div
                              className={cn(
                                "w-1.5 h-1.5 rounded-full",
                                currentProject?.id === projectData.project.id
                                  ? "bg-primary"
                                  : "bg-muted-foreground/40"
                              )}
                            />
                            {projectData.project.name}
                          </div>
                        </SidebarMenuButton>
                      </SidebarMenuItem>
                    ))
                  ) : (
                    <SidebarMenuItem>
                      <div className="text-sm text-muted-foreground">
                        No projects yet
                      </div>
                    </SidebarMenuItem>
                  )}
                  <SidebarMenuItem>
                    <SidebarMenuButton asChild>
                      <Link href="/code/developer" className="text-blue-500">
                        + Add New Project
                      </Link>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                </SidebarMenu>
              </SidebarGroupContent>
            </CollapsibleContent>
          </SidebarGroup>
        </Collapsible>

        {/* Rest of the sidebar menu */}
        {data.navMain.map((item) => (
          <SidebarGroup key={item.title}>
            <SidebarGroupLabel>{item.title}</SidebarGroupLabel>
            <SidebarGroupContent>
              <SidebarMenu>
                {item.items.map((item) => (
                  <SidebarMenuItem key={item.title}>
                    <SidebarMenuButton asChild url={item.url}>
                      <Link href={item.url}>{item.title}</Link>
                    </SidebarMenuButton>
                  </SidebarMenuItem>
                ))}
              </SidebarMenu>
            </SidebarGroupContent>
          </SidebarGroup>
        ))}
      </SidebarContent>
      <SidebarRail />
    </Sidebar>
  );
}
