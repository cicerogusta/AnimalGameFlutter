import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart'as stt;

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

  Animal({required this.resposta,
    required this.audioAsset,
    required this.imagemAsset});
}

class User {
  final String nome;
  final String email;
  final String senha;

  User({required this.nome, required this.email, required this.senha});

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'email': email,
      'senha': senha,
    };
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final player = AudioPlayer();

  void _playSound() {
    try {
      player.setReleaseMode(ReleaseMode.loop);
      player.play(AssetSource('gamemusic.mp3'));
    } catch (e) {
      print('Erro ao reproduzir áudio: $e');
      // Lidar com o erro ou fornecer feedback ao usuário, se necessário
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playSound();
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // TODO: implement dispose
    player.stop();
    player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    if (state == AppLifecycleState.paused) {
      player.stop();
    }

    if (state == AppLifecycleState.detached) {
      player.stop();
    }

    if (state == AppLifecycleState.inactive) {
      player.stop();
    }
    if (state == AppLifecycleState.resumed) {
      _playSound();
    }
  }

  @override
  Widget build(BuildContext context) {
    _playSound();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 147, 202, 228),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: 250,
              height: 250,
              margin: EdgeInsets.symmetric(vertical: 21, horizontal: 0),
              child: Text(
                "SEJA BEM-VINDO(A) \n \n ESCOLHA UM JOGO PARA COMEÇAR:",
                style: TextStyle(
                    fontSize: 28
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  AnimalScreen(musicPlayer: player),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            child: const Text(
              "Adivinhação",
              style: TextStyle(
                fontSize: 25,
              ),
            ),
          ),
          SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FalaParaTextoScreen(musicPlayer: player)
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            child: const Text(
              "Falar Animal",
              style: TextStyle(
                fontSize: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  Future login() async {
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
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
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/logo-ifpb-pdf.png',
                            width: 250,
                            height: 250,
                          ),
                          Text(
                            'NomeAnimal',
                            style: TextStyle(
                              color: Color.fromARGB(255, 51, 4, 219),
                              fontSize: 45,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(45),
                    )),
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                //height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: SizedBox(
                    child: Column(
                      children: [
                        // Container(
                        //   width: 250,
                        //   height: 250,
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 20,
                          ),
                          child: Text(
                            'Faça seu Login:',
                            style: TextStyle(
                                fontFamily: 'Giraffe',
                                fontSize: 30.0,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
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
                                    borderSide:
                                    BorderSide(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(20)),
                                labelText: "Email",
                                labelStyle: TextStyle(color: Colors.black)),
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
                                  borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(20),
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
                        Text(
                          'Não tem conta?',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 10),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const RegisterPage()),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: 12,
                              ),
                              child: Text(
                                'Registre-se',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterPageState extends State<RegisterPage> {
  final databaseReference = FirebaseDatabase.instance.reference();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  Future registrar() async {
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );
      print("Login bem-sucedido: ${userCredential.user!.uid}");
      User user = User(
          nome: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          senha: _senhaController.text.trim());
      Map<String, dynamic> userMap = user.toJson();
      databaseReference.child('users').push().set(userMap);
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
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCDDEFF),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
          height: MediaQuery
              .of(context)
              .size
              .height,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 35,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.only(left: 12),
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.arrow_back_ios),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 22),
                            child: Text(
                              'Registre-se',
                              style: TextStyle(
                                fontFamily: 'Giraffe',
                                fontSize: 45.0,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: TextField(
                          controller: _nomeController,
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
                              borderSide:
                              BorderSide(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: "Nome",
                            hintStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
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
                              borderSide:
                              BorderSide(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: "Email",
                            hintStyle: TextStyle(color: Colors.black),
                          ),
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
                              borderSide:
                              BorderSide(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: "Senha",
                            hintStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          registrar();
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
                              "Registrar",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimalScreen extends StatefulWidget {

  final AudioPlayer musicPlayer;

  AnimalScreen({required this.musicPlayer});

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
    Future.delayed(Duration.zero, () {
      exibirMensagemBV(context, animalSelecionado);
    });
  }

  void exibirMensagemBV(BuildContext context, Animal animal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('JOGO DE ADIVINHAÇÃO'), // Remova o título
          content: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Torna o AlertDialog menor
              children: [
                Image.asset(
                  animal.imagemAsset,
                  width: 100, // ajuste conforme necessário
                  height: 100,
                ),
                SizedBox(height: 10), // Espaçamento entre a imagem e o texto
                Text(
                    'ADIVINHE A LETRA QUE ESTA FALTANDO USANDO A IMAGEM E O SOM TOCANDO NA IMAGEM, E ABAIXO SELECIONE A LETRA QUE ESTÁ FALTANDO',
                    textAlign: TextAlign.center),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  void _selecionarNovoAnimal() {
    try {
      listaDeAnimais.shuffle();
      animalSelecionado = listaDeAnimais.first;
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
          parabens(context);
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
        title: Text("JOGO DE ADIVINHAÇÃO"),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'TOQUE NA IMAGEM:',
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
                InkWell(
                  onTap: () {
                    _playSound();
                   widget.musicPlayer.pause();
                    Future.delayed(Duration(seconds: 12), () {
                      widget.musicPlayer.resume();
                    });
                  },
                  child: Image.asset(
                    animalSelecionado.imagemAsset,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'QUE ANIMAL É ESTE? $respostaAtual',
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

  void parabens(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          widthFactor: 0.8, // Defina a largura do AlertDialog como 80% da largura da tela
          child: AlertDialog(
            title: Text('PARABÉNS!'),
            content: Column(
              mainAxisSize: MainAxisSize.min, // Use MainAxisSize.min para permitir que o AlertDialog diminua em altura
              children: [
                Text('VOCÊ ACERTOU!'),
                SizedBox(height: 10),
                Image.asset(
                  'assets/confetti-gif-1.gif', // Substitua pelo caminho da sua imagem
                  height: 100, // Ajuste a altura da imagem conforme necessário
                  width: 100, // Ajuste a largura da imagem conforme necessário
                ),
              ],
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Ajuste o padding do conteúdo
            titlePadding: EdgeInsets.all(15), // Ajuste o padding do título
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Fechar'),
              ),
            ],
          ),
        );
      },
    );
  }

}

class FalaParaTextoScreen extends StatefulWidget {

  final AudioPlayer musicPlayer;

  FalaParaTextoScreen({required this.musicPlayer});

  @override
  _FalaParaTextoScreenState createState() => _FalaParaTextoScreenState();
}

class _FalaParaTextoScreenState extends State<FalaParaTextoScreen> {

  final player = AudioPlayer();
  late Animal animalSelecionado;
  late String respostaAtual;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String resultText = "";
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
      resposta: 'LEÃO',
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

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {

      exibirMensagemBV(context, animalSelecionado);
    });
    _speech = stt.SpeechToText();
    _selecionarNovoAnimal();

  }

  void _listen() async {
    widget.musicPlayer.stop();
    if (!_isListening) {

      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            resultText = val.recognizedWords;
            if(resultText == animalSelecionado.resposta.toLowerCase()) {
              parabens(context);
              widget.musicPlayer.resume();
              _reiniciarJogoComDelay();
            } else if (resultText.isEmpty){
              print("VAZIO");
            } else if(resultText != animalSelecionado.resposta.toLowerCase()){
              erro(context);
              widget.musicPlayer.resume();
            }


          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();

    }
  }

  void exibirMensagemBV(BuildContext context, Animal animal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('JOGO FALAR ANIMAL'),
          content: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  animal.imagemAsset,
                  width: 100, // ajuste conforme necessário
                  height: 100,
                ),
                SizedBox(height: 10), // Espaçamento entre a imagem e o texto
                Text(
                    'TOQUE NA IMAGEM, OUÇA O SOM DO ANIMAL E DEPOIS TOQUE NO MICROFONE E DIGA QUAL É O ANIMAL',
                    textAlign: TextAlign.center),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _playSoundAnimal() {
    player.play(AssetSource(animalSelecionado.audioAsset));
  }

  void parabens(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          widthFactor: 0.8, // Defina a largura do AlertDialog como 80% da largura da tela
          child: AlertDialog(
            title: Text('PARABÉNS!'),
            content: Column(
              mainAxisSize: MainAxisSize.min, // Use MainAxisSize.min para permitir que o AlertDialog diminua em altura
              children: [
                Text('VOCÊ ACERTOU!'),
                SizedBox(height: 10),
                Image.asset(
                  'assets/confetti-gif-1.gif', // Substitua pelo caminho da sua imagem
                  height: 100, // Ajuste a altura da imagem conforme necessário
                  width: 100, // Ajuste a largura da imagem conforme necessário
                ),
              ],
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Ajuste o padding do conteúdo
            titlePadding: EdgeInsets.all(15), // Ajuste o padding do título
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Fechar'),
              ),
            ],
          ),
        );
      },
    );
  }






  void _selecionarNovoAnimal() {
    animalSelecionado = listaDeAnimais[Random().nextInt(listaDeAnimais.length)];
    respostaAtual = '_${animalSelecionado.resposta.substring(1)}';
  }


  /// Request microphone permission
  Future<void> _requestMicrophonePermission() async {
    await Permission.microphone
        .onDeniedCallback(() {
      // Your code
    })
        .onGrantedCallback(() {


    })
        .onPermanentlyDeniedCallback(() {
      // Your code
    })
        .onRestrictedCallback(() {
      // Your code
    })
        .onLimitedCallback(() {
      // Your code
    })
        .onProvisionalCallback(() {
      // Your code
    })
        .request();
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      // Duração do toast (Toast.LENGTH_SHORT ou Toast.LENGTH_LONG)
      gravity: ToastGravity.BOTTOM,
      // Posição do toast (TOP, BOTTOM, CENTER)
      timeInSecForIosWeb: 1,
      // Duração no iOS
      backgroundColor: Colors.black,
      // Cor de fundo
      textColor: Colors.white,
      // Cor do texto
      fontSize: 16.0, // Tamanho da fonte
    );
  }


  void _reiniciarJogoComDelay() {
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _selecionarNovoAnimal();
      });
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("JOGO FALAR ANIMAL"),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'TOQUE NA IMAGEM:',
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
                InkWell(
                  onTap: () {
                    _playSoundAnimal();
                    widget.musicPlayer.pause();
                    Future.delayed(Duration(seconds: 12), () {
                      widget.musicPlayer.resume();
                    });
                  },
                  child: Image.asset(
                    animalSelecionado.imagemAsset,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'QUAL O ANIMAL?',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: () {
                    _listen();
                  },
                  tooltip: 'Listen',
                  child: Icon(
                      _speech.isNotListening ? Icons.mic_off : Icons.mic),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void erro(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          widthFactor: 0.8, // Defina a largura do AlertDialog como 80% da largura da tela
          child: AlertDialog(
            title: Text('NÃO FOI DESSA VEZ!'),
            content: Column(
              mainAxisSize: MainAxisSize.min, // Use MainAxisSize.min para permitir que o AlertDialog diminua em altura
              children: [
                Text('TENTE NOVAMENTE'),
                SizedBox(height: 10),
                Image.asset(
                  'assets/no-way-x.gif', // Substitua pelo caminho da sua imagem
                  height: 100, // Ajuste a altura da imagem conforme necessário
                  width: 100, // Ajuste a largura da imagem conforme necessário
                ),
              ],
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Ajuste o padding do conteúdo
            titlePadding: EdgeInsets.all(15), // Ajuste o padding do título
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Fechar'),
              ),
            ],
          ),
        );
      },
    );
  }
}
