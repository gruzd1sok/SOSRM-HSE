import 'package:flutter/material.dart';
import 'package:my_app/network_layer/network.dart';
import 'package:my_app/screens/workplace_detail.dart';

class WorkplacesPage extends StatefulWidget {
  const WorkplacesPage({super.key});

  @override
  State<WorkplacesPage> createState() => _WorkplacesPageState();
}

class _WorkplacesPageState extends State<WorkplacesPage> {
  Future<List<WorkplaceData>?> _getWorkspaces() async {
    final workplaces = await getAllWorkspaces();
    return workplaces;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WorkplaceData>?>(
      future: _getWorkspaces(),
      builder: (context, AsyncSnapshot<List<WorkplaceData>?> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != null) {
            return SingleChildScrollView(
              child: Column(
                children: List.generate(
                  snapshot.data!.length,
                  (index) => _Workplace(
                    workplace: snapshot.data![index],
                    onTap: (workplace) => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            WorkplaceDetail(workplace: workplace),
                      ),
                    ),
                    isLast: index + 1 == snapshot.data!.length,
                  ),
                ),
              ),
            );
          } else {
            return const Text('error');
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class _Workplace extends StatelessWidget {
  const _Workplace({
    super.key,
    required this.workplace,
    required this.onTap,
    required this.isLast,
  });
  final WorkplaceData workplace;
  final Function(WorkplaceData) onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(workplace),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                  width: 150,
                  height: 100,
                  child: Image.network(workplace.image),
                ),
                const SizedBox(width: 30),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workplace.name,
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Время работы: \n${workplace.workTime}',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      workplace.metro,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ],
            ),
          ),
          if (!isLast)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                height: 1,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}
