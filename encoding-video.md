# Convert Video
just convert to webm portable video.
```sh
#!/bin/sh

input=${1-""}
output=${2-"output.webm"}

usage() {
  printf "Please input correct params: \n\t$0 input.mov [output.webm]\n"
  exit 1
}

[[ "$input" != "" ]] || usage

echo "Starting to convert $input to $output"
ffmpeg -i $input -vf scale=1920:-1 -vcodec libvpx-vp9 -an $output
echo "please checkout $output"
```



from: https://gist.github.com/Vestride/278e13915894821e1d6f


# Encoding Video

### Installing

Install FFmpeg with homebrew. You'll need to install it with a couple flags for webm and the AAC audio codec.

```shell
brew install ffmpeg --with-libvpx --with-libvorbis --with-fdk-aac --with-opus
```

If you already have ffmpeg installed, but not with the other libraries, use the `reinstall` command.

```shell
brew reinstall ffmpeg --with-opus
```

[FFmpeg options](https://ffmpeg.org/ffmpeg.html#Options). The `-c:v` option is an alias for `-vcodec` and `-c:a` is an alias for `-acodec`. `-crf` is Constant Rate Factor.

### Constant Rate Factor

> This method allows the encoder to attempt to achieve a certain output quality for the whole file when output file size is of less importance. This provides maximum compression efficiency with a single pass. Each frame gets the bitrate it needs to keep the requested quality level. The downside is that you can't tell it to get a specific filesize or not go over a specific size or bitrate.

## Convert to MP4

When converting to an MP4, you want to use the h264 video codec and the aac audio codec because IE11 and earlier only support this combination. The [FFmpeg and H.264 Encoding Guide](https://trac.ffmpeg.org/wiki/Encode/H.264) can walk you through some of the H.264 specific options.

```shell
ffmpeg -i input.mov -vcodec h264 -acodec aac -strict -2 output.mp4
```

For maximum compatibility, use the `profile` option. This may, however, increase the bit rate quite a bit. You can disable the audio stream with the `-an` option. `-pix_fmt yuv420p` is for Apple Quicktime support.

In this example, `input.mov` is converted to `output.mp4` with maximum compatibility, with Quicktime support, and without an audio stream.

```shell
ffmpeg -an -i input.mov -vcodec libx264 -pix_fmt yuv420p -profile:v baseline -level 3 output.mp4
```

## Convert to WebM

#### VP8

`libvpx` is the VP8 video encoder for ​WebM. [FFmpeg and WebM Encoding Guide](https://trac.ffmpeg.org/wiki/Encode/VP8) will walk you through webm specifics.

In this example, `input.mov` is converted to `output.webm` with a constant rate factor of `10` (lower is higher quality) at a bitrate of `1M`. Changing the bitrate to something lower (e.g. `700K`) will result in lower file sizes and lower quality. If your video does not have audio, you may leave off the `-acodec libvorbis` part.

```shell
ffmpeg -i input.mov -vcodec libvpx -qmin 0 -qmax 50 -crf 10 -b:v 1M -acodec libvorbis output.webm
```

#### VP9

VP9 can encode videos at half the file size :smile::clap: You can check out Google's [VP9 encoding guide](https://sites.google.com/a/webmproject.org/wiki/ffmpeg/vp9-encoding-guide) for their recommend settings or the [FFmpeg VP9 guide](https://trac.ffmpeg.org/wiki/Encode/VP9).

Here's an example from the FFmpeg guide:

```shell
ffmpeg -i input.mov -vcodec libvpx-vp9 -b:v 1M -acodec libvorbis output.webm
```

And here's Google's "Best Quality (Slowest) Recommended Settings". You need to run the first line(s). It will create a log file (and warn you the out.webm is empty). On the second pass, the video will be output.

```shell
ffmpeg -i <source> -c:v libvpx-vp9 -pass 1 -b:v 1000K -threads 1 -speed 4 \
  -tile-columns 0 -frame-parallel 0 -auto-alt-ref 1 -lag-in-frames 25 \
  -g 9999 -aq-mode 0 -an -f webm /dev/null


ffmpeg -i <source> -c:v libvpx-vp9 -pass 2 -b:v 1000K -threads 1 -speed 0 \
  -tile-columns 0 -frame-parallel 0 -auto-alt-ref 1 -lag-in-frames 25 \
  -g 9999 -aq-mode 0 -c:a libopus -b:a 64k -f webm out.webm
```

## Support

As of January 2015, all major browsers support MP4.

Data current as of May 2019. Sources:

* jwplayer's [research](http://www.jwplayer.com/html5/)
* caniuse for [AV1](https://caniuse.com/#feat=av1)
* caniuse for [MPEG-4/H.264](http://caniuse.com/#feat=mpeg4)
* caniuse for [HEVC/H.265](http://caniuse.com/#feat=hevc)
* caniuse for [WebM](http://caniuse.com/#feat=webm)

| Browser               | AV1 | H264 | H265           | VP8 | VP9            | AAC | MP3 | VORBIS | OPUS |
|-----------------------|-----|------|----------------|-----|----------------|-----|-----|--------|------|
| Chrome for Desktop    | 70  | 30   | -              | 30  | 30             | 30  | 30  | 30     | 33   |
| Chrome for Android    | -   | 30   | -              | 30  | 30             | 30  | 30  | 30     | -    |
| IE                    | -   | 9    | 10<sup>1</sup> | -   | -              | 9   | 9   | -      | -    |
| IE Mobile             | -   | 10   | -              | -   | -              | 10  | 10  | -      | -    |
| Edge                  | 75  | 12   | 12<sup>1</sup> | -   | 14<sup>2</sup> | 12  | 12  | -      | 14   |
| Firefox for Desktop   | 67  | 22   | -              | 20  | 28             | 22  | 22  | 20     | 20   |
| Firefox for Android   | -   | 20   | -              | 20  | 28             | 20  | 20  | 20     | 20   |
| Safari for Mac        | -   | 3    | 11<sup>3</sup> | -   | -              | 3   | 3   | -      | -    |
| Safari for iOS        | -   | 3    | 11<sup>3</sup> | -   | -              | 3   | 3   | -      | -    |
| Opera for Desktop     | 57  | 25   | -              | 11  | 16             | -   | -   | 11     | 12   |
| Android Stock Browser | -   | 2.3  | -              | 4.0 | 5              | 2.3 | 2.3 | 4.0    | -    |

### Notes

1. Supported only for devices with [hardware support](https://answers.microsoft.com/en-us/insider/forum/insider_apps-insider_wmp/windows-10-hevc-playback-yes-or-no/3c1ab780-a6b2-4b77-ac0f-9faeefd4680d).
2. Edge 14+ has [partial support](https://blogs.windows.com/msedgedev/2016/04/18/webm-vp9-and-opus-support-in-microsoft-edge/) for VP9
3. Supported only on macOS High Sierra and onwards.

### Recommended markup

Since all browsers support MP4, we can use WebM's VP9 codec for modern browsers and fall back to MP4s for the rest.

```html
<video>
  <source src="path/to/video.webm" type="video/webm; codecs=vp9,vorbis">
  <source src="path/to/video.mp4" type="video/mp4">
</video>
```

## Creating thumbnail images from the video

Here's their [guide](https://trac.ffmpeg.org/wiki/Create%20a%20thumbnail%20image%20every%20X%20seconds%20of%20the%20video). Output a single frame from the video.

```shell
ffmpeg -i input.mp4 -ss 00:00:14.435 -vframes 1 out.png
```

Output one image every second as a jpg.

```shell
ffmpeg -i input.mp4 -vf fps=1 out%3d.jpg
```

## Reversing a video

FFmpeg now has a [reverse filter](https://ffmpeg.org/ffmpeg-filters.html#toc-reverse). Usage: (source from [this video.stackexchange answer](https://video.stackexchange.com/a/17739))

For video only:

```shell
ffmpeg -i input.mp4 -vf reverse reversed.mp4
```

For audio and video:

```shell
ffmpeg -i input.mp4 -vf reverse -af areverse reversed.mp4
```

This filter buffers the entire clip. For larger files, segment the file, reverse each segment and then concat the reversed segments.

