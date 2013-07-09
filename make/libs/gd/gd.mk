$(call PKG_INIT_LIB, 2.1.0)
$(PKG)_LIB_VERSION:=3.0.0
$(PKG)_SOURCE:=libgd-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=03588159bf4faab9079849c8d709acc6
$(PKG)_SITE:=https://bitbucket.org/libgd/gd-libgd/downloads

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/libgd-$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libgd.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgd.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libgd.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON := jpeg libpng freetype zlib

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --with-fontconfig=no
$(PKG)_CONFIGURE_OPTIONS += --with-freetype="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-jpeg="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-png="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-tiff=no
$(PKG)_CONFIGURE_OPTIONS += --with-vpx=no
$(PKG)_CONFIGURE_OPTIONS += --with-x=no
$(PKG)_CONFIGURE_OPTIONS += --with-xpm=no
$(PKG)_CONFIGURE_OPTIONS += --with-zlib="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GD_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(GD_DIR)/src \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-libLTLIBRARIES install-includeHEADERS
	$(SUBMAKE) -C $(GD_DIR)/config \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgd.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/gdlib.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/gdlib-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GD_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgd.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/gdlib.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/{entities,gdcache,gd_color_map,gd_errors,gdfontg,gdfontl,gdfontmb,gdfonts,gdfontt,gdfx,gd,gd_io,gdpp}.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/gdlib-config

$(pkg)-uninstall:
	$(RM) $(GD_TARGET_DIR)/libgd*.so*

$(PKG_FINISH)
