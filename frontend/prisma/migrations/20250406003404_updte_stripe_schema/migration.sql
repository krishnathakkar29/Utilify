/*
  Warnings:

  - You are about to drop the column `currentPeriodEnd` on the `StripeSubscription` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "StripeSubscription" DROP COLUMN "currentPeriodEnd";
