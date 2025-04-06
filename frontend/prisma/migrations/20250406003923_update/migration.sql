/*
  Warnings:

  - You are about to drop the `StripeSubscription` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "User" DROP CONSTRAINT "User_stripeSubscriptionId_fkey";

-- DropTable
DROP TABLE "StripeSubscription";

-- CreateTable
CREATE TABLE "UserSubscription" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "stripe_customer_id" TEXT NOT NULL,
    "stripe_subscription_id" TEXT,
    "stripe_price_id" TEXT,
    "stripe_current_period_end" TIMESTAMP(3),

    CONSTRAINT "UserSubscription_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "UserSubscription_userId_key" ON "UserSubscription"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "UserSubscription_stripe_customer_id_key" ON "UserSubscription"("stripe_customer_id");

-- CreateIndex
CREATE UNIQUE INDEX "UserSubscription_stripe_subscription_id_key" ON "UserSubscription"("stripe_subscription_id");

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_stripeSubscriptionId_fkey" FOREIGN KEY ("stripeSubscriptionId") REFERENCES "UserSubscription"("id") ON DELETE SET NULL ON UPDATE CASCADE;
