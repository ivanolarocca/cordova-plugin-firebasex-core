interface FirebasexCorePlugin {
    getInstallationId(success: (id: string) => void, error: (err: string) => void): void;
    getInstallationToken(success: (token: string) => void, error: (err: string) => void): void;
    deleteInstallationId(success: () => void, error: (err: string) => void): void;
    getId(success: (id: string) => void, error: (err: string) => void): void;
    registerInstallationIdChangeListener(fn: (id: string) => void): void;
    registerApplicationDidBecomeActiveListener(fn: () => void): void;
    registerApplicationDidEnterBackgroundListener(fn: () => void): void;
}

declare var FirebasexCore: FirebasexCorePlugin;
