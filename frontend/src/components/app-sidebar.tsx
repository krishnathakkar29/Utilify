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

export function AppSidebar({ ...props }: React.ComponentProps<typeof Sidebar>) {
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
        {/* We create a SidebarGroup for each parent. */}
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
