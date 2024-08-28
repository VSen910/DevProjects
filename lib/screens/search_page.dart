import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projects_app/screens/user_page.dart';
import 'package:projects_app/utilities/providers.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var users = ref.watch(searchUserProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        title: SizedBox(
          width: double.infinity,
          height: 50,
          child: TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search users',
              hintStyle: const TextStyle(color: Colors.grey),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.yellow.shade400),
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            onChanged: (val) async {
              ref.watch(searchStringProvider.notifier).state = val;
              if (val.isNotEmpty) {
                users = await ref.refresh(searchUserProvider);
              }
            },
          ),
        ),
      ),
      body: users.when(
        data: (data) {
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    ref.read(selectedUserEmailProvider.notifier).state =
                        data[index]['email'];

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserPage(),
                      ),
                    );
                  },
                  child: Ink(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 45,
                            width: 45,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Image.network(data[index]['picturePath']),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data[index]['email'],
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                data[index]['name'],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        error: (error, st) {
          print(error);
          print(st);
          return const Text('Some error occurred');
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
