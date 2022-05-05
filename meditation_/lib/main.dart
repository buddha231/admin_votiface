import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:web3dart/web3dart.dart';

enum appState {
  scanner,
  qr,
  text,
}
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  appState current_state = appState.text;
  String privateKey =
      '96e61ea5a49f785830522f4e1f195dfde1fab97ee816a62202168e597bdcbb70';
  // String rpcUrl = 'http://192.168.17.113:8545';
  String rpcUrl = 'https://kovan.infura.io/v3/5eddb680b6cf4ea0936f900b9269b4e9';
  String contractAddress = "0x910C23D26b8Ab871a6c8c3570aBB0D2d381e3726";
  late Client httpClient;
  late Web3Client ethereumClient;
  String publicKey = "";
  String contractName = "Voting";
  late EthPrivateKey credentials;

  @override
  void initState() {
    super.initState();
    credentials = EthPrivateKey.fromHex(privateKey);
    httpClient = Client();
    ethereumClient = Web3Client(rpcUrl, httpClient);
  }

  Future<DeployedContract> getContract() async {
    String contractJson =
        await rootBundle.loadString("assets/contract/Voting.json");
    var jsonAbi = jsonDecode(contractJson);
    var abi = jsonEncode(jsonAbi['abi']);

    DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(abi, contractName),
      EthereumAddress.fromHex(contractAddress),
    );

    return contract;
  }

  Future<void> submit(String functionName, List<dynamic> args) async {
    // EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
    DeployedContract contract = await getContract();
    final ethFunction = contract.function(functionName);
    final result = await ethereumClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: args,
      ),
      fetchChainIdFromNetworkId: true,
      chainId: null,
    );
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    MobileScannerController cameraController = MobileScannerController();
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: current_state != appState.scanner
          ? Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(
                        () {
                          // current_state = appState.qr;
                          if (current_state == appState.qr) {
                            current_state = appState.text;
                          } else {
                            current_state = appState.qr;
                          }
                          print(publicKey);
                        },
                      );
                    },
                    child: const Text("toggle"),
                  ),
                  (current_state == appState.text)
                      ? Text(publicKey.toString())
                      : Column(
                          children: [
                            QrImage(
                              data: publicKey.toString(),
                              version: QrVersions.auto,
                              size: 200.0,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                submit(
                                  "giveRightToVote",
                                  [
                                    EthereumAddress.fromHex(
                                        publicKey.toString().trim()),
                                    "1234",
                                    "1"
                                  ],
                                );
                              },
                              child: Text("give_right"),
                            )
                          ],
                        ),
                  FloatingActionButton(
                    child: Icon(Icons.play_arrow),
                    onPressed: () {
                      setState(() {
                        current_state = appState.scanner;
                      });
                    },
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      IconButton(
                        color: Colors.black,
                        icon: ValueListenableBuilder(
                          valueListenable: cameraController.torchState,
                          builder: (context, state, child) {
                            switch (state as TorchState) {
                              case TorchState.off:
                                return const Icon(Icons.flash_off,
                                    color: Colors.grey);
                              case TorchState.on:
                                return const Icon(Icons.flash_on,
                                    color: Colors.yellow);
                            }
                          },
                        ),
                        iconSize: 32.0,
                        onPressed: () => cameraController.toggleTorch(),
                      ),
                      IconButton(
                        color: Colors.black,
                        icon: ValueListenableBuilder(
                          valueListenable: cameraController.cameraFacingState,
                          builder: (context, state, child) {
                            switch (state as CameraFacing) {
                              case CameraFacing.front:
                                return const Icon(Icons.camera_front);
                              case CameraFacing.back:
                                return const Icon(Icons.camera_rear);
                            }
                          },
                        ),
                        iconSize: 32.0,
                        onPressed: () => cameraController.switchCamera(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: MobileScanner(
                    allowDuplicates: false,
                    controller: cameraController,
                    onDetect: (barcode, args) {
                      final String? code = barcode.rawValue;
                      setState(() {
                        current_state = appState.qr;
                        publicKey = code.toString();
                      });
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
