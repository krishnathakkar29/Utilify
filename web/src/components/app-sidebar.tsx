import { AppSidebarCompoent } from "@/components/app-sidebar-component";
import { getQueryClient } from "@/lib/get-query-client";
import { dehydrate, HydrationBoundary } from "@tanstack/react-query";
import React from "react";
import { getUserProjects } from "../../actions/project";

export async function AppSidebar() {
  const queryClient = getQueryClient();

  await queryClient.prefetchQuery({
    queryKey: ["projects"],
    queryFn: async () => {
      const response = await getUserProjects();
      if (!response.success) {
        throw new Error(response.message);
      }
      return response.data;
    },
  });

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <AppSidebarCompoent />;
    </HydrationBoundary>
  );
}
