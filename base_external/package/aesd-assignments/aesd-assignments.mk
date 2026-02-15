##############################################################
#
# AESD-ASSIGNMENTS
#
##############################################################

# Pseudocode Block 1: define where Buildroot fetches assignment sources.
# - Pin to a specific commit for reproducible builds.
# - Use the SSH URL required by assignment infrastructure.
AESD_ASSIGNMENTS_VERSION = a0e2040ebe68f4d7fdb79219223b96dd336fbe20
AESD_ASSIGNMENTS_SITE = git@github.com:cu-ecen-aeld/assignments-3-and-later-jsnapoli1.git
AESD_ASSIGNMENTS_SITE_METHOD = git
AESD_ASSIGNMENTS_GIT_SUBMODULES = YES

# Pseudocode Block 2: cross-compile binaries using Buildroot toolchain variables.
# - Build finder-app userspace tools used by the provided test scripts.
# - Build server/aesdsocket so the executable matches the target architecture.
define AESD_ASSIGNMENTS_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/finder-app all
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/server all
endef

# Pseudocode Block 3: stage runtime assets into rootfs.
# - Place configuration in /etc/finder-app/conf.
# - Install CLI tools and service executable to /usr/bin.
# - Install init script as S99 service hook for startup/shutdown handling.
define AESD_ASSIGNMENTS_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/etc/finder-app/conf
	$(INSTALL) -m 0644 $(@D)/conf/* $(TARGET_DIR)/etc/finder-app/conf/
	$(INSTALL) -d $(TARGET_DIR)/usr/bin
	$(INSTALL) -m 0755 $(@D)/finder-app/writer $(TARGET_DIR)/usr/bin/writer
	$(INSTALL) -m 0755 $(@D)/finder-app/finder.sh $(TARGET_DIR)/usr/bin/finder.sh
	$(INSTALL) -m 0755 $(@D)/server/aesdsocket $(TARGET_DIR)/usr/bin/aesdsocket
	$(INSTALL) -m 0755 $(BR2_EXTERNAL_project_base_PATH)/package/aesd-assignments/finder-test.sh $(TARGET_DIR)/usr/bin/finder-test.sh
	$(INSTALL) -d $(TARGET_DIR)/etc/init.d
	$(INSTALL) -m 0755 $(@D)/server/aesdsocket-start-stop $(TARGET_DIR)/etc/init.d/S99aesdsocket
endef

$(eval $(generic-package))
