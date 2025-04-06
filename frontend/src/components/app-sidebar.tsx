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
          title: "Cloud in a Minute",
          url: "/documents/documenthosting",
        },
        {
          title: "CSV & Excel Conversions",
          url: "/documents/excelcsv",
        },
        {
          title: "Query Your Documents",
          url: "/documents/query",
        },
        {
          title: "Pdf Functions",
          url: "/documents/pdf",
        },
        {
          title: "Image Manipulations",
          url: "/documents/imageconversion",
        },
        {
          title: "Image To Text",
          url: "/documents/ocr",
        },
      ],
    },

    {
      title: "Code And Conquer",
      url: "#",
      items: [
        {
          title: "Web Compiler",
          url: "/code/compiler",
        },
        {
          title: "Formatter",
          url: "/code/formatter",
        },
        {
          title: "Code Language Converter",
          url: "/code/convertor",
        },
        {
          title: "Talk to DataBase",
          url: "/code/databaseoperations",
        },
        {
          title: "Coding Assitant",
          url: "/code/codeassistant",
        },
        {
          title: "Api Tester",
          url: "/code/apitester",
        },
      ],
    },
    {
      title: "Work",
      url: "#",
      items: [
        {
          title: "OutReact At Ease",
          url: "/work/mail/send-mail",
        },
        {
          title: "Mail History",
          url: "/work/mail/view-history",
        },
        {
          title: "QR & Barcode Generator",
          url: "/work/qrgenerator",
        },
        {
          title: "Todo List",
          url: "/work/todo",
        },
        {
          title: "Text To Speech",
          url: "/work/tts",
        },
      ],
    },
    {
      title: "Everyday Tools",
      url: "#",
      items: [
        {
          title: "Converter Utilities",
          url: "/everyday/clock",
        },
        {
          title: "Color Pallette At Ease",
          url: "/everyday/color-pallete",
        },
      ],
    },
    {
      title: "Security & Network",
      url: "#",
      items: [
        {
          title: "Network",
          url: "/network",
        },
        {
          title: "Security",
          url: "/security",
        },
      ],
    },
    {
      title: "Settings",
      url: "#",
      items: [
        {
          title: "Settings",
          url: "/settings",
        },
        {
          title: "Request Features",
          url: "/request",
        },
        {
          title: "View Requested Features",
          url: "/view-features",
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
      console.log(response);
      return response.data;
    },
    retry: 3,
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
