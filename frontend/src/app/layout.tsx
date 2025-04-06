import { Toaster } from "@/components/ui/sonner";
import { ClerkProvider } from "@clerk/nextjs";
import type { Metadata } from "next";
import { Space_Grotesk } from "next/font/google";
import "./globals.css";
import { ThemeProvider } from "@/components/wrappers/theme-provider";
import { CompilerProvider } from "@/context/compiler-context";
import QueryProviderWrapper from "@/components/wrappers/query-provider";
import { ProjectProvider } from "@/context/project-context";
import { FeatureRequestProvider } from "@/context/feature-context";

const space = Space_Grotesk({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Create Next App",
  description: "Generated by create next app",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <ClerkProvider>
      <html lang="en" suppressHydrationWarning>
        <body className={`${space.className}`}>
          <QueryProviderWrapper>
            <CompilerProvider>
              <ProjectProvider>
                <FeatureRequestProvider>
                  <ThemeProvider
                    attribute="class"
                    defaultTheme="dark"
                    enableSystem
                    disableTransitionOnChange
                  >
                    {children}
                    <Toaster
                      position="bottom-right"
                      expand={true}
                      richColors
                      theme="dark"
                      closeButton
                      style={{ marginBottom: "20px" }}
                    />
                  </ThemeProvider>
                </FeatureRequestProvider>
              </ProjectProvider>
            </CompilerProvider>
          </QueryProviderWrapper>
        </body>
      </html>
    </ClerkProvider>
  );
}
