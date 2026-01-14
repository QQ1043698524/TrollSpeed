#ifndef LIBROOT_H
#define LIBROOT_H

#include <sys/cdefs.h>
#include <sys/param.h>

#ifdef __cplusplus
extern "C" {
#endif

// libroot.dylib

const char *libroot_get_root_prefix(void);
const char *libroot_get_jbroot_prefix(void);
const char *libroot_get_boot_uuid(void);
char *libroot_jbrootpath(const char *path, char *resolvedPath);
char *libroot_rootfspath(const char *path, char *resolvedPath);

// Macros

#define JBROOT_PATH_CSTRING(path) libroot_jbrootpath(path, NULL)
#define ROOTFS_PATH_CSTRING(path) libroot_rootfspath(path, NULL)

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#define JBROOT_PATH_NSSTRING(path) [NSString stringWithUTF8String:libroot_jbrootpath(path.UTF8String, NULL)]
#define ROOTFS_PATH_NSSTRING(path) [NSString stringWithUTF8String:libroot_rootfspath(path.UTF8String, NULL)]
#endif

#ifdef __cplusplus
}
#endif

#endif /* LIBROOT_H */
