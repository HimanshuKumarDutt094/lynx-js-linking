/// <reference path="./global.d.ts" />

export async function openURL(url: string): Promise<void> {
  return new Promise((resolve, reject) => {
    try {
      NativeModules.LynxLinkingModule.openURL(url, (err?: string) => {
        if (err) reject(new Error(err));
        else resolve();
      });
    } catch (e) {
      reject(e);
    }
  });
}

export async function openSettings(): Promise<void> {
  return new Promise((resolve, reject) => {
    try {
      NativeModules.LynxLinkingModule.openSettings((err?: string) => {
        if (err) reject(new Error(err));
        else resolve();
      });
    } catch (e) {
      reject(e);
    }
  });
}

export async function sendIntent(
  action: string,
  extras?: Array<{ key: string; value: any }>
): Promise<void> {
  return new Promise((resolve, reject) => {
    try {
      NativeModules.LynxLinkingModule.sendIntent(
        action,
        extras,
        (err?: string) => {
          if (err) reject(new Error(err));
          else resolve();
        }
      );
    } catch (e) {
      reject(e);
    }
  });
}

export async function share(
  content: string,
  options?: { mimeType?: string; dialogTitle?: string }
): Promise<void> {
  return new Promise((resolve, reject) => {
    try {
      NativeModules.LynxLinkingModule.share(
        content,
        options,
        (err?: string) => {
          if (err) reject(new Error(err));
          else resolve();
        }
      );
    } catch (e) {
      reject(e);
    }
  });
}

export default {
  openURL,
  openSettings,
  sendIntent,
  share,
};
