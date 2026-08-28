import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../controllers/tutor_controller.dart';
import '../widgets/tutor_bubble_entrance.dart';
import '../widgets/tutor_input_bar.dart';
import '../widgets/tutor_message_bubble.dart';
import '../widgets/tutor_typing_bubble.dart';

/// The main lesson screen: a running conversation with the AI Tutor for
/// one curriculum topic. Started by TutorTopicsPage via
/// TutorController.startSession before this page is pushed.
class TutorChatPage extends ConsumerStatefulWidget {
  final String topicTitle;

  const TutorChatPage({super.key, required this.topicTitle});

  @override
  ConsumerState<TutorChatPage> createState() => _TutorChatPageState();
}

class _TutorChatPageState extends ConsumerState<TutorChatPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tutorControllerProvider);
    final controller = ref.read(tutorControllerProvider.notifier);

    ref.listen(tutorControllerProvider, (previous, next) {
      final messageCountChanged =
          next.messages.length != (previous?.messages.length ?? 0);
      final startedSending = next.sending && !(previous?.sending ?? false);
      if (messageCountChanged || startedSending) {
        _scrollToBottom();
      }
    });

    final completed = state.session?.isCompleted ?? false;
    final assessing = state.session?.state == 'ASSESS_PRIOR_KNOWLEDGE';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.topicTitle, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (assessing && !completed)
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: state.sending ? null : controller.skipAssessment,
                        icon: const Icon(Icons.fast_forward_rounded, size: 18),
                        label: const Text('Skip assessment'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.subtitle),
                      ),
                    ),
                  ),
                if (state.error != null)
                  Container(
                    width: double.infinity,
                    color: AppColors.danger.withAlpha(20),
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: AppColors.danger, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length + (state.sending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.messages.length) {
                        return const TutorBubbleEntrance(
                          key: ValueKey('typing'),
                          child: TutorTypingBubble(),
                        );
                      }
                      final message = state.messages[index];
                      return TutorBubbleEntrance(
                        key: ValueKey(message.id),
                        alignment: message.isTutor
                            ? Alignment.bottomLeft
                            : Alignment.bottomRight,
                        child: TutorMessageBubble(
                          message: message,
                          onQuizAnswer: (answer) => controller.sendMessage(answer),
                        ),
                      );
                    },
                  ),
                ),
                if (completed)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: const Text(
                      "🎉 Lesson complete! Head back to pick another topic.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
                    ),
                  )
                else
                  TutorInputBar(
                    sending: state.sending,
                    onSendText: controller.sendMessage,
                    onSendVoice: controller.sendVoiceMessage,
                  ),
              ],
            ),
    );
  }
}
