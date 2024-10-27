import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../components/AppWidgets.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'PdfViewWidget.dart';
import 'TableViewWidget.dart';
import 'TweetWebWidget.dart';
import 'VimeoEmbedWidget.dart';
import 'YouTubeEmbedWidget.dart';

class HtmlWidget extends StatelessWidget {
  final String? postContent;
  final Color? color;

  HtmlWidget({this.postContent, this.color});

  @override
  Widget build(BuildContext context) {
    return Html(
      data: postContent!,
      onLinkTap: (s, _, __, ___) async {
        if (s!.split('/').last.contains('.pdf')) {
          PdfViewWidget(pdfUrl: s).launch(context);
        } else {
          launchUrlWidget(s, forceWebView: false);
        }
      },
      onImageTap: (s, _, __, ___) {
        openPhotoViewer(context, Image.network(s!).image);
      },
      style: {
        'embed': Style(color: color ?? transparentColor, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'strong': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'a': Style(color: color ?? Colors.blue, fontWeight: FontWeight.bold, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'div': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'figure': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble()), padding: EdgeInsets.zero, margin: EdgeInsets.zero),
        'h1': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'h2': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'h3': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'h4': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'h5': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'h6': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'ol': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'ul': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'li': Style(
            color: color ?? textPrimaryColorGlobal,
            fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble()),
            listStyleType: ListStyleType.DISC,
            listStylePosition: ListStylePosition.OUTSIDE,
            lineHeight: LineHeight(1.2)),
        'strike': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'u': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'b': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'i': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'hr': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'header': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'code': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'data': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'body': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'big': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'blockquote': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'audio': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
        'img': Style(width: context.width(), padding: EdgeInsets.only(bottom: 8), fontSize: FontSize(getIntAsync(FONT_SIZE_PREF, defaultValue: 18).toDouble())),
      },
      customRender: {
        "img": (RenderContext renderContext, Widget child) {
          log(renderContext.parser.htmlData);

          return cachedImage(renderContext.parser.htmlData.text).onTap(() {
            //
          });
        },
        "youtube": (RenderContext renderContext, Widget child) {
          log(renderContext.parser.htmlData);
          return YouTubeEmbedWidget(renderContext.parser.htmlData.text.splitBetween('<youtube>', '</youtube').toYouTubeId());
        },
        "vimeo": (RenderContext renderContext, Widget child) {
          log(renderContext.parser.htmlData);

          return VimeoEmbedWidget(renderContext.parser.htmlData.text.splitBetween('<vimeo>', '</vimeo'));
        },
        "figure": (RenderContext renderContext, Widget child) {
          if (renderContext.tree.element!.innerHtml.contains('youtu.be')) {
            log("${renderContext.tree.element!.innerHtml.splitBetween('<div class="wp-block-embed__wrapper">', "</div>")}");
            return YouTubeEmbedWidget(renderContext.tree.element!.innerHtml.splitBetween('<div class="wp-block-embed__wrapper">', "</div>").replaceAll('<br>', '').toYouTubeId());
          } else if (renderContext.tree.element!.innerHtml.contains('vimeo')) {
            return VimeoEmbedWidget(renderContext.tree.element!.innerHtml.splitBetween('<div class="wp-block-embed__wrapper">', "</div>").replaceAll('<br>', '').splitAfter('com/'));
          } else if (renderContext.tree.element!.innerHtml.contains('audio')) {
            return Container(
                width: context.width(),

                child: Html(data:  renderContext.tree.element!.innerHtml,).center());
            // return AudioPostWidget(postString: renderContext.tree.element!.innerHtml);
          } else {
            return child;
            // return child;
          }
        },
        "iframe": (RenderContext renderContext, Widget child) {
          return YouTubeEmbedWidget(renderContext.tree.attributes['src']!.toYouTubeId());
        },
        "img": (RenderContext renderContext, Widget child) {
          String img = '';
          if (renderContext.tree.attributes.containsKey('src')) {
            img = renderContext.tree.attributes['src']!;
          } else if (renderContext.tree.attributes.containsKey('data-src')) {
            img = renderContext.tree.attributes['data-src']!;
          }
          return cachedImage(img).cornerRadiusWithClipRRect(defaultRadius).onTap(() {
            openPhotoViewer(context, NetworkImage(img));
          });
        },
        "blockquote": (RenderContext renderContext, Widget child) {
          return TweetWebView(tweetUrl: renderContext.tree.element!.outerHtml);
        },
        "table": (RenderContext renderContext, Widget child) {
          return Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.open_in_full_rounded),
                  onPressed: () async {
                    await TableViewWidget(renderContext).launch(context);
                    setOrientationPortrait();
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: (renderContext.tree as TableLayoutElement).toWidget(renderContext),
              ),
            ],
          );
        },
      },
    );
  }
}
