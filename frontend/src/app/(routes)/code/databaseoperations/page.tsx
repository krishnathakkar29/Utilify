import SubscriptionButton from "@/components/common/subscription-button";
import TalkDb from "@/components/pages/code/talk-db";
import { Button } from "@/components/ui/button";
import { checkSubscription } from "@/lib/subscription";
import { currentUser } from "@clerk/nextjs/server";
import Link from "next/link";
import React from "react";

async function page() {
  const user = await currentUser();

  const isPro = await checkSubscription();

  if (!user) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen bg-gray-900 text-white">
        <h1 className="text-3xl font-bold">
          Please log in to access this page
        </h1>
        <Link href="/sign-in">
          <Button className="mt-4 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition duration-200">
            Sign In
          </Button>
        </Link>
      </div>
    );
  }

  if (!isPro && user) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen bg-gray-900 text-white">
        <h1 className="text-3xl font-bold">
          This feature is only available for Pro users.
        </h1>
        <SubscriptionButton isPro={isPro} />
      </div>
    );
  }

  return <TalkDb />;
}

export default page;
