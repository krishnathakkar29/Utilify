/*
  Warnings:

  - You are about to drop the column `stripe_current_period_end` on the `UserSubscription` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "UserSubscription" DROP COLUMN "stripe_current_period_end";
