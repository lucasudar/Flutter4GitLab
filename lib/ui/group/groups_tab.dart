import 'package:F4Lab/model/group.dart';
import 'package:F4Lab/widget/comm_ListView.dart';
import 'package:flutter/material.dart';

class TabGroups extends CommListWidget {
  TabGroups() : super(canPullUp: false, withPage: false);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends CommListState<TabGroups> {
  @override
  Widget build(BuildContext context) {
    return data != null
        ? GridView.builder(
            itemCount: data.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemBuilder: (context, index) {
              return childBuild(context, index);
            }).build(context)
        : super.build(context);
  }

  @override
  Widget childBuild(BuildContext context, int index) {
    final item = data[index];
    return _buildItem(item);
  }

  Widget _buildItem(item) {
    final group = Group.fromJson(item);
    return Card(
      child: InkWell(
        onTap: () {
          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text("${group.name}: ${group.description}"),
              backgroundColor: Theme.of(context).accentColor,
            ),
          );
        },
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: CircleAvatar(
              radius: 40,
              child: Text(
                group.name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  String endPoint() => "groups";
}
