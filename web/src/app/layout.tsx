import type { Metadata } from "next";
import { Geist, Geist_Mono, Space_Grotesk } from "next/font/google";
import "./globals.css";
import { Toaster } from "@/components/ui/sonner";
import QueryProviderWrapper from "@/components/wrappers/query-provider";
import { CompilerProvider } from "@/context/compiler-context";
import { ThemeProvider } from "@/components/wrappers/theme-provider";
import { ProjectProvider } from "@/context/project-context";
import { SessionProvider } from "next-auth/react";

const space = Space_Grotesk({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Utilify",
  description:
    "Utilify is a powerful tool for developers, providing a suite of utilities to enhance productivity and streamline workflows.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className={`${space.className}`}>
        <QueryProviderWrapper>
          <ProjectProvider>
            <CompilerProvider>
              {children}
              <Toaster
                position="bottom-right"
                expand={true}
                richColors
                theme="dark"
                closeButton
                style={{ marginBottom: "20px" }}
              />
            </CompilerProvider>
          </ProjectProvider>
        </QueryProviderWrapper>
      </body>
    </html>
  );
}
