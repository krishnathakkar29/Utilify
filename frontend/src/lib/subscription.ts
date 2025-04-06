import { currentUser } from "@clerk/nextjs/server";
import prisma from "./db";

const DAY_IN_MS = 1000 * 60 * 60 * 24;

export const checkSubscription = async () => {
  const session = await currentUser();
  if (!session) {
    return false;
  }

  const dbUser = await prisma.user.findUnique({
    where: {
      clerkUserId: session.id,
    },
  });
  if (!dbUser) {
    return false;
  }
  const userSubscription = await prisma.userSubscription.findUnique({
    where: {
      userId: dbUser.id,
    },
  });
  if (!userSubscription) {
    return false;
  }

  const isValid = userSubscription.stripePriceId;

  return !!isValid;
};
