import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    home: LoginPage(),
  ));
}

class Animal {
  final String resposta;
  final String audioAsset;
  final String imagemAsset;

  Animal(
      {required this.resposta,
      required this.audioAsset,
      required this.imagemAsset});
}

class HomeScreen extends StatelessWidget {
  final player = AudioPlayer();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnimalScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: const Text("Iniciar Adivinhação"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FalaParaTextoScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: const Text("Iniciar Fala para texto"),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  Future login() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );
      print("Login bem-sucedido: ${userCredential.user!.uid}");
      _navigateHomeScreen();
    } catch (e) {
      print("Erro no login: $e");
    }
  }

  void _navigateHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCDDEFF),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            // Container(
            //   width: 250,
            //   height: 250,
            // ),
            Text(
              'Faça seu Login',
              style: TextStyle(
                  fontFamily: 'Giraffe', fontSize: 60.0, color: Colors.blue),
            ),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: TextField(
                controller: _emailController,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(20.0),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    hintText: "Email",
                    hintStyle: TextStyle(color: Colors.black)),
              ),
            ),
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: TextField(
                obscureText: true,
                controller: _senhaController,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(20.0),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    hintText: "Senha",
                    hintStyle: TextStyle(color: Colors.black)),
              ),
            ),
            SizedBox(height: 25),
            GestureDetector(
              onTap: () {
                login();
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.symmetric(horizontal: 120),
                decoration: BoxDecoration(
                  color: Color(0xFF2C3DBF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    "Entrar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 25),
            Text('Não tem conta?'),
            SizedBox(width: 10),
            Text(
              'Registre-se',
              style: TextStyle(color: Colors.blue),
            )
          ],
        ),
      ),
    );
  }
}

class AnimalScreen extends StatefulWidget {
  const AnimalScreen({super.key});

  @override
  _AnimalScreenState createState() => _AnimalScreenState();
}

class _AnimalScreenState extends State<AnimalScreen> {
  final player = AudioPlayer();
  late Animal animalSelecionado;
  late String respostaAtual;
  String? letraSelecionada;
  Set<String> letrasIncorretas = Set();
  final List<Animal> listaDeAnimais = [
    Animal(
      resposta: 'CACHORRO',
      audioAsset: 'filhote_latindo.wav',
      imagemAsset: 'assets/cachorro.png',
    ),
    Animal(
      resposta: 'GATO',
      audioAsset: 'gato.mp3',
      imagemAsset: 'assets/gato.png',
    ),
    Animal(
      resposta: 'LEAO',
      audioAsset: 'leao.mp3',
      imagemAsset: 'assets/leao.png',
    ),
    Animal(
      resposta: 'ELEFANTE',
      audioAsset: 'elefante.mp3',
      imagemAsset: 'assets/elefante.png',
    ),
    // Adicione mais animais conforme necessário
  ];

  final List<String> letrasAZ = List.generate(
      26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index));

  @override
  void initState() {
    super.initState();
    _selecionarNovoAnimal();
  }

  void _selecionarNovoAnimal() {
    try {
      animalSelecionado =
          listaDeAnimais[Random().nextInt(listaDeAnimais.length)];
      respostaAtual = '_${animalSelecionado.resposta.substring(1)}';
      letraSelecionada = null;
      letrasIncorretas.clear();
    } catch (e) {
      print('Erro ao carregar recursos do animal: $e');
      // Lidar com o erro ou fornecer feedback ao usuário, se necessário
    }
  }

  void _playSound() {
    try {
      player.play(AssetSource(animalSelecionado.audioAsset));
    } catch (e) {
      print('Erro ao reproduzir áudio: $e');
      // Lidar com o erro ou fornecer feedback ao usuário, se necessário
    }
  }

  void _reiniciarJogoComDelay() {
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _selecionarNovoAnimal();
      });
    });
  }

  void _atualizarTexto(String letra) {
    int indexUnderscore = respostaAtual.indexOf('_');
    if (animalSelecionado.resposta.startsWith(letra) && indexUnderscore != -1) {
      setState(() {
        respostaAtual = respostaAtual.replaceFirst('_', letra);
        letraSelecionada = letra;
        if (!respostaAtual.contains('_') &&
            animalSelecionado.resposta == respostaAtual) {
          _showDialog();
          _reiniciarJogoComDelay();
        }
      });
      print('Resposta contém a letra inicial: $letra');
    } else {
      setState(() {
        letraSelecionada = letra;
        letrasIncorretas.add(letra);
        letrasAZ.shuffle();
      });
      print('Resposta não contém a letra inicial ou já está completa: $letra');
    }
  }

  @override
  Widget build(BuildContext context) {
    letrasAZ.shuffle();
    return Scaffold(
      appBar: AppBar(
        title: Text("Jogo de Adivinhação"),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Toque na imagem:',
                  style: TextStyle(fontSize: 18, color: Colors.yellow),
                ),
                InkWell(
                  onTap: () {
                    _playSound();
                  },
                  child: Image.asset(
                    animalSelecionado.imagemAsset,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Que animal é esse? $respostaAtual',
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: letrasAZ.map((letra) {
                    return ElevatedButton(
                      onPressed: () {
                        _atualizarTexto(letra);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: letrasIncorretas.contains(letra)
                            ? Colors.red
                            : Colors.blue,
                      ),
                      child: Text(letra),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Parabéns, você acertou!'),
          content: Text('A resposta é: ${animalSelecionado.resposta}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}

class FalaParaTextoScreen extends StatefulWidget {
  const FalaParaTextoScreen({Key? key}) : super(key: key);

  @override
  _FalaParaTextoScreenState createState() => _FalaParaTextoScreenState();
}

class _FalaParaTextoScreenState extends State<FalaParaTextoScreen> {
  final player = AudioPlayer();
  late Animal animalSelecionado;
  late String respostaAtual;
  final SpeechToText _speechToText = SpeechToText();
  String _currentWords = '';
  final List<Animal> listaDeAnimais = [
    Animal(
      resposta: 'CACHORRO',
      audioAsset: 'assets/filhote_latindo.wav',
      imagemAsset: 'assets/cachorro.png',
    ),

    // Adicione mais animais conforme necessário
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _selecionarNovoAnimal();
  }

  void _playSound() {
    player.play(AssetSource(animalSelecionado.audioAsset));
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Parabéns, você acertou!'),
          content: Text('A resposta é: ${animalSelecionado.resposta}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _selecionarNovoAnimal() {
    animalSelecionado = listaDeAnimais[Random().nextInt(listaDeAnimais.length)];
    respostaAtual = '_${animalSelecionado.resposta.substring(1)}';
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  /// Request microphone permission
  Future<void> _requestMicrophonePermission() async {
    if (await Permission.microphone.request().isGranted) {
      // Microphone permission granted, you can now initialize speech recognition
      _initSpeech();
    } else {
      // Permission denied
      // You can handle this case, show a message to the user, or request permission again
    }
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    if (await Permission.microphone.isGranted) {
      await _speechToText.listen(onResult: _onSpeechResult);
      setState(() {});
    } else {
      // Microphone permission is not granted, request it
      _requestMicrophonePermission();
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _currentWords = result.recognizedWords;
      print(_currentWords);
      if (_currentWords.contains(animalSelecionado.resposta.toLowerCase())) {
        _showDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jogo Falar Animal"),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Toque na imagem:',
                  style: TextStyle(fontSize: 18, color: Colors.yellow),
                ),
                InkWell(
                  onTap: () {
                    _playSound();
                  },
                  child: Image.asset(
                    animalSelecionado.imagemAsset,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Qual o animal?',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: () {
                    _startListening();
                  },
                  tooltip: 'Listen',
                  child: Icon(
                      _speechToText.isNotListening ? Icons.mic_off : Icons.mic),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
