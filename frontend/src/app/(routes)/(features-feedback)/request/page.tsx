"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import React from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";

import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle
} from "@/components/ui/card";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { ToolCategory, useFeatureRequests } from "@/context/feature-context";
import { toast } from "sonner";

const formSchema = z.object({
  title: z
    .string()
    .min(5, "Title must be at least 5 characters")
    .max(100, "Title must be less than 100 characters"),
  description: z
    .string()
    .min(20, "Description must be at least 20 characters")
    .max(500, "Description must be less than 500 characters"),
  category: z.enum([
    "Text Formatter",
    "CSV & Excel Tools",
    "API Tools",
    "Image & Graphic Converters",
    "Code Formatter",
    "Password Generator",
    "Random Number Generator",
    "Network Utilities",
    "Other",
  ] as const),
});

type FormValues = z.infer<typeof formSchema>;

const FeatureRequestForm: React.FC = () => {
  const { addRequest } = useFeatureRequests();

  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      title: "",
      description: "",
      category: "Text Formatter",
    },
  });

  const onSubmit = (data: FormValues) => {
    addRequest(data.title, data.description, data.category as ToolCategory);

    toast.success("Your feature is submitted");

    form.reset();
  };

  return (
    <Card className="w-full max-w-2xl shadow-lg border border-accent/10">
      <CardHeader className="space-y-1">
        <CardTitle className="text-2xl font-bold">Request a Feature</CardTitle>
        <CardDescription>
          Submit your feature request to help us improve our tool ecosystem.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
            <FormField
              control={form.control}
              name="title"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Feature Title</FormLabel>
                  <FormControl>
                    <Input
                      placeholder="Enter a concise title for your feature"
                      {...field}
                      className="bg-background/50"
                    />
                  </FormControl>
                  <FormDescription>
                    Keep it short and descriptive.
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="category"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Tool Category</FormLabel>
                  <Select
                    onValueChange={field.onChange}
                    defaultValue={field.value}
                  >
                    <FormControl>
                      <SelectTrigger className="bg-background/50">
                        <SelectValue placeholder="Select a category" />
                      </SelectTrigger>
                    </FormControl>
                    <SelectContent>
                      <SelectItem value="Text Formatter">
                        Text Formatter
                      </SelectItem>
                      <SelectItem value="CSV & Excel Tools">
                        CSV & Excel Tools
                      </SelectItem>
                      <SelectItem value="API Tools">API Tools</SelectItem>
                      <SelectItem value="Image & Graphic Converters">
                        Image & Graphic Converters
                      </SelectItem>
                      <SelectItem value="Code Formatter">
                        Code Formatter
                      </SelectItem>
                      <SelectItem value="Password Generator">
                        Password Generator
                      </SelectItem>
                      <SelectItem value="Random Number Generator">
                        Random Number Generator
                      </SelectItem>
                      <SelectItem value="Network Utilities">
                        Network Utilities
                      </SelectItem>
                      <SelectItem value="Other">Other</SelectItem>
                    </SelectContent>
                  </Select>
                  <FormDescription>
                    Select the category that best fits your feature request.
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="description"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Description</FormLabel>
                  <FormControl>
                    <Textarea
                      placeholder="Provide details about the feature you'd like to see"
                      className="min-h-[120px] bg-background/50"
                      {...field}
                    />
                  </FormControl>
                  <FormDescription>
                    Explain what the feature should do and why it would be
                    useful.
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            <Button
              type="submit"
              className="w-full bg-accent hover:bg-accent/90"
            >
              Submit Request
            </Button>
          </form>
        </Form>
      </CardContent>
    </Card>
  );
};

export default FeatureRequestForm;
