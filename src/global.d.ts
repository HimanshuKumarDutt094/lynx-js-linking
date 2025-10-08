/// <reference types="@lynx-js/types" />

declare global {
  // Extend the existing NativeModules interface to include LynxLinkingModule
  interface NativeModules {
    LynxLinkingModule: {
      openURL(url: string, callback: (err?: string) => void): void;
      openSettings(callback: (err?: string) => void): void;
      sendIntent(
        action: string,
        extras?: Array<{ key: string; value: any }>,
        callback?: (err?: string) => void
      ): void;
      share(
        content: string,
        options?: { mimeType?: string; dialogTitle?: string },
        callback?: (err?: string) => void
      ): void;
    };
  }
}

export {};
