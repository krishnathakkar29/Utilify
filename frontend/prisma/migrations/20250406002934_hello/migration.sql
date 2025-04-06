/*
  Warnings:

  - A unique constraint covering the columns `[stripeSubscriptionId]` on the table `User` will be added. If there are existing duplicate values, this will fail.

*/
-- AlterTable
ALTER TABLE "User" ADD COLUMN     "stripeSubscriptionId" TEXT;

-- CreateTable
CREATE TABLE "StripeSubscription" (
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "userId" TEXT,
    "subscriptionId" TEXT,
    "productId" TEXT,
    "priceId" TEXT,
    "customerId" TEXT,
    "currentPeriodEnd" TIMESTAMP(3) NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "StripeSubscription_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "StripeSubscription_userId_key" ON "StripeSubscription"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "StripeSubscription_subscriptionId_key" ON "StripeSubscription"("subscriptionId");

-- CreateIndex
CREATE UNIQUE INDEX "User_stripeSubscriptionId_key" ON "User"("stripeSubscriptionId");

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_stripeSubscriptionId_fkey" FOREIGN KEY ("stripeSubscriptionId") REFERENCES "StripeSubscription"("id") ON DELETE SET NULL ON UPDATE CASCADE;
