import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text_project/bloc/home/home_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _initSpeech();
    _searchController.addListener(() {
      final query = _searchController.text;
      context.read<HomeBloc>().add(SearchDataEvent(searchText: query));
      setState(() {});
    });
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening(BuildContext context) async {
    await _speechToText.listen(
        onResult: (result) {
          _onSpeechResult(result, context);
        },
        listenFor: const Duration(seconds: 15),
        listenOptions: SpeechListenOptions(
          cancelOnError: false,
          partialResults: false,
          listenMode: ListenMode.confirmation,
        ));
    setState(() {});
  }

  void _stopListening(BuildContext context) async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result, BuildContext context) {
    setState(() {
      _lastWords = result.recognizedWords;
      _searchController.text = _lastWords;
    });

    context.read<HomeBloc>().add(SearchDataEvent(searchText: _lastWords));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(FetchDataEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is LoadingState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is ErrorState) {
          return Expanded(child: Text(state.errorMessage));
        } else if (state is LoadedState) {
          return Column(
            children: [
              _textFieldWidget(context),
              Expanded(
                child: ListView.builder(
                    itemCount: state.user.length,
                    itemBuilder: (context, index) {
                      final user = state.user[index];
                      return ListTile(
                        title: Text(user.name),
                        subtitle: Text(user.username),
                      );
                    }),
              ),
            ],
          );
        }
        return Container();
      },
    );
  }

  String _getSpeechStatusMessage() {
    if (_speechToText.isListening) {
      return _lastWords;
    } else if (_speechEnabled) {
      return 'Tap the microphone to start listening...';
    } else {
      return 'Speech not available';
    }
  }

  Widget _textFieldWidget(BuildContext context) {
    return TextFormField(
        controller: _searchController,
        cursorColor: Colors.grey,
        onChanged: (value) {
          context.read<HomeBloc>().add(SearchDataEvent(searchText: value));
        },
        decoration: InputDecoration(
          iconColor: Colors.grey,
          hintText: _getSpeechStatusMessage(),
          filled: true,
          prefixIcon: const IconTheme(
            data: IconThemeData(
              color: Colors.grey,
            ),
            child: Icon(Icons.search),
          ),
          suffixIcon: _searchController.text.isEmpty
              ? IconTheme(
                  data: const IconThemeData(
                    color: Colors.grey,
                  ),
                  child: InkWell(
                    onTap: () {
                      _speechToText.isNotListening
                          ? _startListening(context)
                          : _stopListening(context);
                    },
                    child: Icon(_speechToText.isNotListening
                        ? Icons.mic
                        : Icons.mic_off),
                  ),
                )
              : IconTheme(
                  data: const IconThemeData(
                    color: Colors.grey,
                  ),
                  child: InkWell(
                    onTap: () {
                      _searchController.clear();
                      context
                          .read<HomeBloc>()
                          .add(SearchDataEvent(searchText: ''));
                      setState(() {});
                    },
                    child: const Icon(Icons.close),
                  ),
                ),
        ));
  }
}
