import 'package:chat/message_model.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class ChatGptScreen extends StatefulWidget {
  const ChatGptScreen({super.key});

  @override
  State<ChatGptScreen> createState() => _ChatGptScreenState();
}

class _ChatGptScreenState extends State<ChatGptScreen> {
  TextEditingController messageController = TextEditingController();
  List<MessageModel> messageList = [];
  bool inProgress = false;

  final openAI = OpenAI.instance.build(
      token: "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",
      baseOption: HttpSetup(receiveTimeout: 30000),
      isLogger: true
    );

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tango"),
      ),
      body: Column(
        children: [
          Expanded(
              child: messageList.isEmpty
                  ? const Center(
                      child: Text(
                        "Bienvenido a TANGO ",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 28, fontFamily: 'monospace'),
                      ),
                    )
                  : buildMessageListWidget()),
          if (inProgress)
            const LinearProgressIndicator(
              minHeight: 2,
            ),
          buildSendWinget(),
        ],
      ),
    );
  }

  Widget buildMessageListWidget() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return buildSingleMessageRow(messageList[index]);
      },
      reverse: true,
      itemCount: messageList.length,
    );
  }

  Widget buildSingleMessageRow(MessageModel messageModel) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Align(
        alignment:
            messageModel.sentByMe ? Alignment.topRight : Alignment.topLeft,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: messageModel.sentByMe
                  ? Colors.blue[200]
                  : Colors.grey.shade300,
            ),
            padding: const EdgeInsets.all(10),
            child: Text(
              messageModel.message,
              style: const TextStyle(
                fontSize: 16,
              ),
            )),
      ),
    );
  }

  Widget buildSendWinget() {
    return Container(
      color: Colors.white,
      height: 60,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: messageController,
            decoration: const InputDecoration(
              hintText: "Como puedo ayudarte el dia de hoy?",
              border: InputBorder.none,
            ),
          )),
          const SizedBox(
            width: 16,
          ),
          FloatingActionButton(
            onPressed: () {
              String question = messageController.text.toString();
              if (question.isEmpty) return;
              messageController.clear();
              addMessageToMessageList(question, true);
              sendMessageToAPI(question);
            },
            elevation: 0,
            child: const Icon(
              Icons.send,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  void sendMessageToAPI(String question) async {
    setState(() {
      inProgress = true;
    });

    final request = CompleteText(
      prompt: question,
      model: kCodeTranslateModelV2,
      maxTokens: 100,
    );
    try {
      final response = await openAI.onCompleteText(request: request);
      String answer = response?.choices.last.text.trim() ?? "";
      addMessageToMessageList(answer, false);
    } catch (e) {
      addMessageToMessageList("Vuelva a intentarlo", false);
    }

    setState(() {
      inProgress = false;
    });
  }

  void addMessageToMessageList(String message, bool sentByMe) {
    setState(() {
      messageList.insert(0, MessageModel(message: message, sentByMe: sentByMe));
    });
  }
}
