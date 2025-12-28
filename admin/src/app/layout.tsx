import type { Metadata } from "next";
import "./globals.css";
import "./config/fontawesome";

export const metadata: Metadata = {
  metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3000'),
  title: {
    default: "Zoea Admin",
    template: "%s | Zoea Admin",
  },
  description: "Zoea Admin Panel - Complete administration system with CRUD operations, analytics dashboards, and reports for Events, Venues, Real Estate, and E-commerce",
  keywords: ["analytics", "dashboard", "zoea", "events", "venues", "real estate", "e-commerce"],
  authors: [{ name: "Zoea" }],
  creator: "Zoea",
  publisher: "Zoea",
  icons: {
    icon: [
      { url: "/favicon.ico", sizes: "any" },
    ],
  },
  openGraph: {
    type: "website",
    locale: "en_US",
    url: process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3000',
    siteName: "Zoea Admin",
    title: "Zoea Admin",
    description: "Zoea Admin Panel - Complete administration system with CRUD operations and analytics",
  },
  robots: {
    index: false,
    follow: false,
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          href="https://fonts.googleapis.com/css2?family=Source+Sans+Pro:wght@400;600;700&display=swap"
          rel="stylesheet"
        />
        <link rel="icon" href="/favicon.ico" sizes="any" />
      </head>
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
}

