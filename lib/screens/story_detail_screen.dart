import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:flutter_quill/widgets/toolbar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:write_story/mixins/hook_controller.dart';
import 'package:write_story/mixins/story_detail_method_mixin.dart';
import 'package:write_story/models/story_model.dart';
import 'package:write_story/notifier/story_detail_screen_notifier.dart';
import 'package:write_story/widgets/vt_ontap_effect.dart';
import 'package:write_story/widgets/w_icon_button.dart';

class StoryDetailScreen extends HookWidget
    with StoryDetailMethodMixin, HookController {
  StoryDetailScreen({
    Key key,
    this.story,
    this.futureId,
    this.forDate,
  })  : assert((story != null && (futureId == null && forDate == null)) ||
            (story == null && (futureId != null && forDate != null))),
        super(key: key);

  /// [story] must be null if
  /// [futureId] and [forDate] is not null
  final StoryModel story;

  /// if [futureId] not null
  /// which mean that this screen
  /// is inserting new story
  final int futureId;

  /// [forDate] must be null,
  /// if [story] is not null
  final DateTime forDate;

  final ValueNotifier<double> headerPaddingTopNotifier =
      ValueNotifier<double>(0);

  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    print("build detail");

    final bool insert = futureId != null;
    final _notifier = useProvider(storydetailScreenNotifier);

    final initTitle = !insert && _notifier.draftStory != null
        ? _notifier.draftStory.title
        : "";

    final initParagraph = !insert && _notifier.draftStory != null
        ? _notifier.draftStory.paragraph
        : "";

    final draftStory = StoryModel(
      id: futureId,
      title: initTitle,
      paragraph: initParagraph,
      createOn: DateTime.now(),
      forDate: forDate,
    );

    _notifier..setDraftStory(!insert ? story : draftStory);

    var json;
    try {
      json = jsonDecode(_notifier.draftStory.paragraph);
    } catch (e) {}

    final quillController = useQuillController(
      document: json != null ? Document.fromJson(json) : null,
      selection: json != null ? TextSelection.collapsed(offset: 0) : null,
      isBasic: json != null ? false : true,
    );

    final scrollController = useScrollController();
    final sliverController = useScrollController();

    quillController.addListener(
      () {
        var json = jsonEncode(quillController.document.toDelta().toJson());
        // print("json hah: $json");
        _notifier
            .setDraftStory(_notifier.draftStory.copyWith(paragraph: "$json"));
      },
    );

    scrollController.addListener(() {
      sliverController.jumpTo(scrollController.offset);
    });

    sliverController.addListener(() {
      double top = lerpDouble(0, MediaQuery.of(context).viewPadding.top,
          sliverController.offset / sliverController.position.maxScrollExtent);
      headerPaddingTopNotifier.value = top;
    });

    final _headerText = buildHeaderTextField(
      insert: insert,
      notifier: _notifier,
      context: context,
    );

    final _scaffoldBody = NestedScrollView(
      controller: sliverController,
      headerSliverBuilder: (context, val) {
        return [
          buildAppBar(
            context: context,
            insert: insert,
            notifier: _notifier,
          ),
        ];
      },
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: headerPaddingTopNotifier,
            builder: (context, value, child) {
              return Padding(
                child: _headerText,
                padding:
                    EdgeInsets.symmetric(horizontal: 16.0).copyWith(top: value),
              );
            },
          ),
          const Divider(height: 0),
          Expanded(
            child: QuillEditor(
              maxHeight: null,
              placeholder: "Write your story here...",
              controller: quillController,
              scrollController: scrollController,
              scrollPhysics: ClampingScrollPhysics(),
              scrollable: true,
              focusNode: focusNode,
              autoFocus: true,
              readOnly: false,
              showCursor: true,
              keyboardAppearance: Theme.of(context).brightness,
              enableInteractiveSelection: true,
              expands: false,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
            ),
          ),
        ],
      ),
    );

    return buildDefinedScaffold(
      context: context,
      notifier: _notifier,
      body: _scaffoldBody,
      controller: quillController,
    );
  }

  TextFormField buildHeaderTextField({
    @required bool insert,
    @required StoryDetailScreenNotifier notifier,
    @required BuildContext context,
  }) {
    final _theme = Theme.of(context);
    return TextFormField(
      autofocus: false,
      textAlign: TextAlign.left,
      initialValue: !insert ? story.title ?? "" : notifier.draftStory.title,
      style: _theme.textTheme.subtitle1.copyWith(height: 1.5),
      maxLines: null,
      onChanged: (String value) {
        notifier.setDraftStory(
          notifier.draftStory.copyWith(title: value),
        );
      },
      keyboardAppearance: Theme.of(context).brightness,
      decoration: InputDecoration(
        hintText: "Your story title...",
        border: InputBorder.none,
      ),
    );
  }

  WillPopScope buildDefinedScaffold({
    @required BuildContext context,
    @required StoryDetailScreenNotifier notifier,
    @required Widget body,
    @required QuillController controller,
  }) {
    final _theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () {
        onPopNavigator(
          context: context,
          notifier: notifier,
        );
        return;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          TextEditingController().clear();
        },
        child: Scaffold(
          backgroundColor: _theme.backgroundColor,
          body: body,
          extendBody: true,
          bottomNavigationBar: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SafeArea(
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: QuillToolbar.basic(
                  controller: controller,
                  toolbarIconSize: 24,
                  showLink: false,
                  showHeaderStyle: false,
                  showCodeBlock: false,
                  showUnderLineButton: true,
                  showHorizontalRule: false,
                  showStrikeThrough: false,
                  showIndent: false,
                  showClearFormat: false,
                  showColorButton: false,
                  showBackgroundColorButton: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAppBar({
    BuildContext context,
    bool insert,
    StoryDetailScreenNotifier notifier,
  }) {
    final _theme = Theme.of(context);

    return SliverAppBar(
      backgroundColor: _theme.backgroundColor,
      centerTitle: false,
      floating: true,
      elevation: 0.5,
      leading: buildAppBarLeadingButton(context: context, notifier: notifier),
      actions: [
        WIconButton(
          iconData: Icons.date_range_rounded,
          onPressed: () async {
            onPickDate(
              context: context,
              date: !insert ? story.forDate : notifier.draftStory.forDate,
            );
          },
        ),
        if (!insert)
          WIconButton(
            iconData: Icons.delete,
            iconColor: _theme.errorColor,
            onPressed: () async => onDelete(
              context: context,
              notifier: notifier,
              insert: insert,
              id: story.id,
            ),
          ),
        WIconButton(
          iconData: Icons.save,
          iconColor: _theme.primaryColor,
          onPressed: () async {
            await onSave(
              notifier: notifier,
              context: context,
              insert: insert,
            );
          },
        ),
        if (!insert)
          WIconButton(
            iconData: Icons.info,
            onPressed: () async {
              final dialog = Dialog(
                child: Container(
                  child: buildAboutDateText(
                    context: context,
                    insert: insert,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                ),
              );
              if (Platform.isIOS) {
                showCupertinoDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return dialog;
                  },
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return dialog;
                  },
                );
              }
            },
          ),
      ],
    );
  }

  Widget buildAppBarLeadingButton({
    @required BuildContext context,
    @required StoryDetailScreenNotifier notifier,
  }) {
    return WIconButton(
      iconData: Icons.cancel,
      onPressed: () {
        onPopNavigator(
          context: context,
          notifier: notifier,
        );
      },
    );
  }

  Widget buildAboutDateText({
    @required BuildContext context,
    @required bool insert,
  }) {
    final _theme = Theme.of(context);
    String _aboutDateText = "";
    if (!insert) {
      _aboutDateText = getDateLabel(
            date: story.createOn,
            context: context,
            label: "Create on",
          ) +
          "\n" +
          getDateLabel(
            date: story.forDate,
            context: context,
            label: "For Date",
          );
    }

    if (!insert && story.updateOn != null) {
      _aboutDateText += "\n" +
          getDateLabel(
            date: story.updateOn,
            context: context,
            label: "Update on",
          );
    }

    final aboutDate = !insert
        ? Text(
            _aboutDateText,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: _theme.textTheme.subtitle2.color.withOpacity(0.6),
            ),
          )
        : const SizedBox();

    return aboutDate;
  }
}
