"use client";
import React from "react";
import { Button } from "@/components/ui/button";
import { Link, PlusCircle } from "lucide-react";
import { FeatureRequest, useFeatureRequests } from "@/context/feature-context";

import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Clock, Calendar } from "lucide-react";

interface RequestCardProps {
  request: FeatureRequest;
}

const RequestCard: React.FC<RequestCardProps> = ({ request }) => {
  const { title, description, category, status, createdAt } = request;

  // Format the date
  const formattedDate = new Intl.DateTimeFormat("en-US", {
    month: "short",
    day: "numeric",
    year: "numeric",
  }).format(createdAt);

  return (
    <Card className="h-full flex flex-col bg-card/80 backdrop-blur-sm border border-accent/10 transition-all duration-300 hover:shadow-md hover:border-accent/20">
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <Badge
            variant={status === "In Progress" ? "default" : "secondary"}
            className={
              status === "In Progress"
                ? "bg-accent text-white"
                : "bg-secondary text-foreground"
            }
          >
            {status}
          </Badge>
          <Badge variant="outline" className="text-xs">
            {category}
          </Badge>
        </div>
        <CardTitle className="text-lg mt-2">{title}</CardTitle>
      </CardHeader>
      <CardContent className="flex-grow">
        <CardDescription className="text-sm line-clamp-4">
          {description}
        </CardDescription>
      </CardContent>
      <CardFooter className="text-muted-foreground text-xs pt-2 flex items-center">
        <Calendar className="h-3 w-3 mr-1" />
        <span>{formattedDate}</span>
      </CardFooter>
    </Card>
  );
};

function page() {
  const { requests } = useFeatureRequests();

  return (
    <div className="container mx-auto py-8 px-4">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-bold mb-2">Feature Requests</h1>
          <p className="text-muted-foreground">
            Browse all the feature requests from our community.
          </p>
        </div>
        <Button asChild className="bg-accent hover:bg-accent/90">
          <Link to="/" className="flex items-center gap-2">
            <PlusCircle size={18} />
            <span>New Request</span>
          </Link>
        </Button>
      </div>

      {requests.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-center">
          <div className="bg-muted/20 p-6 rounded-full mb-4">
            <PlusCircle size={48} className="text-muted-foreground" />
          </div>
          <h2 className="text-xl font-medium mb-2">No requests yet</h2>
          <p className="text-muted-foreground max-w-md mb-6">
            Be the first to request a feature for our tool ecosystem. Your input
            helps us improve!
          </p>
          <Button asChild className="bg-accent hover:bg-accent/90">
            <Link to="/">Submit a Request</Link>
          </Button>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {requests.map((request) => (
            <RequestCard key={request.id} request={request} />
          ))}
        </div>
      )}
    </div>
  );
}

export default page;
