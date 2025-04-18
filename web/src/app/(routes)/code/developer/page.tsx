"use client";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import React from "react";
import { useForm } from "react-hook-form";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { useRouter } from "next/navigation";
import { createProject } from "../../../../../actions/project";

interface FormInput {
  repoUrl: string;
  projectName: string;
}

function page() {
  const router = useRouter();
  const { register, handleSubmit, reset } = useForm<FormInput>();
  const queryClient = useQueryClient(); // Use the existing QueryClient from provider

  const mutation = useMutation({
    mutationFn: async (data: FormInput) => {
      const response = await createProject(data.repoUrl, data.projectName);
      if (!response.success) {
        throw new Error(response.message);
      }
      return response;
    },
    onSuccess: (data) => {
      toast.success(data.message);
      reset();
      queryClient.invalidateQueries({
        queryKey: ["projects"],
      });
      router.refresh();
    },
    onError: (error) => {
      toast.error(error.message || "Failed to create project");
    },
  });

  const onSubmit = (data: FormInput) => {
    mutation.mutate(data);
  };

  return (
    <div className="flex items-center justify-center h-full">
      <div>
        <div>
          <h1 className="font-semibold text-2xl">Link your github repo</h1>
          <p className="text-sm text-muted-foreground">
            Enter URL of the github repo
          </p>
        </div>
        <div className="h-4"></div>
        <div>
          <form onSubmit={handleSubmit(onSubmit)}>
            <Input
              {...register("repoUrl", {
                required: true,
              })}
              placeholder="RepoUrl"
            />
            <div className="h-2"></div>
            <Input
              {...register("projectName", {
                required: true,
              })}
              placeholder="Project Name"
            />
            <div className="h-2"></div>
            <Button type="submit">Create project</Button>
          </form>
        </div>
      </div>
    </div>
  );
}

export default page;
