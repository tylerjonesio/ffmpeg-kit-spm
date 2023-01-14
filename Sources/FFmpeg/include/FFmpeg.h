#ifndef BRIDGE_H
#define BRIDGE_H

#include <libavcodec/avcodec.h>
#include <libavcodec/bsf.h>

#include <libavdevice/avdevice.h>

#include <libavfilter/avfilter.h>
#include <libavfilter/buffersink.h>
#include <libavfilter/buffersrc.h>

#include <libavformat/avformat.h>
#include <libavformat/avio.h>

#include <errno.h>
#include <stddef.h>
#include <libavutil/avutil.h>
#include <libavutil/common.h>
#include <libavutil/error.h>
#include <libavutil/opt.h>
#include <libavutil/file.h>
#include <libavutil/log.h>
#include <libavutil/timestamp.h>
#include <libavutil/pixdesc.h>
#include <libavutil/imgutils.h>
#include <libavutil/channel_layout.h>
#include <libavutil/md5.h>
#include <libavutil/mastering_display_metadata.h>

#include <libswresample/swresample.h>
#include <libswscale/swscale.h>

#endif
