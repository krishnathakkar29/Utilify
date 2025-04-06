import prisma from "@/lib/db";
import { stripe } from "@/lib/stripe";
import { headers } from "next/headers";
import { NextResponse } from "next/server";
import Stripe from "stripe";

export async function POST(req: Request) {
  const body = await req.text();
  const signature = (await headers()).get("Stripe-Signature") as string;
  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      "whsec_e468314ae3f7b5ecfa44abc47eeb67c1aeeb83fa55468d530091d25036dbc6d4"
    );
  } catch (error: any) {
    console.error("Webhook signature verification failed:", error.message);
    return new NextResponse(`Webhook Error: ${error.message}`, { status: 400 });
  }

  try {
    const session = event.data.object as Stripe.Checkout.Session;

    if (event.type === "checkout.session.completed") {
      const subscription = await stripe.subscriptions.retrieve(
        session.subscription as string
      );

      const customerEmail = session.customer_details?.email;
      if (!customerEmail) {
        throw new Error("No customer email found in session");
      }

      // Find the user by email
      const user = await prisma.user.findUnique({
        where: { email: customerEmail },
      });

      if (!user) {
        throw new Error(`No user found with email ${customerEmail}`);
      }

      // Create or update subscription
      await prisma.userSubscription.create({
        data: {
          userId: user.id,
          stripeSubscriptionId: subscription.id,
          stripeCustomerId: subscription.customer as string,
          stripePriceId: subscription.items.data[0].price.id,
        },
      });
    }

    if (event.type === "invoice.payment_succeeded") {
      const subscription = await stripe.subscriptions.retrieve(
        session.subscription as string
      );

      await prisma.userSubscription.update({
        where: {
          stripeSubscriptionId: subscription.id,
        },
        data: {
          stripePriceId: subscription.items.data[0].price.id,
        },
      });
    }

    return new NextResponse(null, { status: 200 });
  } catch (error: any) {
    console.error("Webhook handler failed:", error.message);
    return new NextResponse(`Webhook Error: ${error.message}`, { status: 500 });
  }
}
