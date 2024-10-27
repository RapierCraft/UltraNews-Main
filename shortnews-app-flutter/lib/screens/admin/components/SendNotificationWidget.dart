import 'package:flutter/material.dart';
import '../../../utils/Colors.dart';
import '/../main.dart';
import '/../network/RestApis.dart';
import '/../utils/Common.dart';
import '/../utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../models/NotificationModel.dart';
import 'PickImageDialog.dart';

class SendNotificationWidget extends StatefulWidget {
  static String tag = '/SendNotificationWidget';

  @override
  SendNotificationWidgetState createState() => SendNotificationWidgetState();
}

class SendNotificationWidgetState extends State<SendNotificationWidget> {
  var formKey = GlobalKey<FormState>();

  TextEditingController titleCont = TextEditingController();
  TextEditingController notificationCont = TextEditingController();
  TextEditingController imageCont = TextEditingController();

  FocusNode notificationFocus = FocusNode();
  FocusNode imageFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  Future<void> onSendClick() async {
    if (appStore.isTester) return toast(mTesterNotAllowedMsg);

    appStore.setLoading(true);
    if (formKey.currentState!.validate()) {
      NotificationClass data = NotificationClass();
      data.title = parseHtmlString(titleCont.text.trim());
      data.img = parseHtmlString(imageCont.text.trim());
      data.dec = parseHtmlString(notificationCont.text.trim());
      data.createdAt = DateTime.now();

      await notificationService.addNotification(data).then((value) async {
        log("value.id" + value.id);
        sendPushNotifications(parseHtmlString(titleCont.text.trim()), parseHtmlString(notificationCont.text.trim()), image: imageCont.text.trim()).then((value) async {
          toast("Notification sent successfully!");
          appStore.setLoading(false);
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e);
        });
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: context.width() * 0.5,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(languages.sendNotificationAllUsers, style: boldTextStyle()),
            16.height,
            AppTextField(
              controller: titleCont,
              textFieldType: TextFieldType.MULTILINE,
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              decoration: inputDecoration(labelText: languages.title),
              nextFocus: notificationFocus,
              autoFocus: true,
              validator: (s) {
                if (s!.trim().isEmpty) return errorThisFieldRequired;
                return null;
              },
            ),
            16.height,
            AppTextField(
              controller: notificationCont,
              focus: notificationFocus,
              textFieldType: TextFieldType.MULTILINE,
              textCapitalization: TextCapitalization.sentences,
              minLines: 4,
              decoration: inputDecoration(labelText: languages.notification),
              nextFocus: imageFocus,
              validator: (s) {
                if (s!.trim().isEmpty) return errorThisFieldRequired;
                return null;
              },
            ),
            16.height,
            AppTextField(
              controller: imageCont,
              focus: imageFocus,
              textFieldType: TextFieldType.MULTILINE,
              decoration: inputDecoration(labelText: languages.imageUrl).copyWith(
                suffixIcon: AppButton(
                  text: languages.media,
                  onTap: () {
                    showInDialog(context, builder: (context) {
                      return PickImageDialog();
                    }, contentPadding: EdgeInsets.zero)
                        .then((value) {
                      if (value != null && value.toString().isNotEmpty) {
                        imageCont.text = value.toString();
                      }
                    });
                  },
                ).paddingRight(8).visible(false),
              ),
              keyboardType: TextInputType.url,
              validator: (s) {
                if (s!.isNotEmpty && !s.validateURL()) return languages.urlInvalid;
                return null;
              },
            ),
            16.height,
            AppButton(
              width: context.width() * 0.5,
              text: languages.send,
              textColor: Colors.white,
              color: colorPrimary,
              padding: EdgeInsets.all(20),
              onTap: () {
                onSendClick();
              },
            ),
          ],
        ),
      ),
    );
  }
}
