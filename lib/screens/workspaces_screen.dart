import 'package:flutter/material.dart';

import 'package:needoff/app_state.dart' show appState, AppStateException;
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/api/storage.dart' as storage;
import 'package:needoff/utils/ui.dart';
import 'package:needoff/parts/widget_mixins.dart' show LoadingState;

class WorkspacesScreen extends StatefulWidget {
  @override
  _WorkspacesScreenState createState() => _WorkspacesScreenState();
}

class _WorkspacesScreenState extends State<WorkspacesScreen> with LoadingState {
  int _activeWSId;

  final _scaffKey = GlobalKey<ScaffoldState>();

  _listOrEmptyMsg() {
    if (appState.workspaces.length == 0) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
            height: MediaQuery.of(context).size.height,
            child: Center(child: Text('No entries found.'))),
      );
    }
    return ListView(
      children:
          ListTile.divideTiles(context: context, tiles: _buildList()).toList(),
    );
  }

  _setCurrentWorkspace(ws) async {
    if (ws.id != null) {
      try {
        int id = ws.id;
        if (await storage.setWorkspace(id)) {
          setState(() {
            _activeWSId = id;
          });
        }
      } catch (e) {
        print('![ERROR] Can not set active workspace');
      }
    }
  }

  List<Widget> _buildList() {
    return appState.workspaces.map((item) {
      bool current = false;
      try {
        current = _activeWSId == item.id ? true : false;
      } catch (e) {}
      return ListTile(
        onTap: () {
          Navigator.of(context)
              .pushNamed('/workspace-profile', arguments: {'id': item.id});
        },
        contentPadding: EdgeInsets.fromLTRB(16, 4, 16, 4),
        title: Text(item.name),
        subtitle: Text(item.description ?? ''),
        trailing: Container(
          padding: EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Colors.grey[200],
                width: 1,
              ),
            ),
          ),
          child: IconButton(
            onPressed: () {
              _setCurrentWorkspace(item);
            },
            icon: Icon(current
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked),
          ),
        ),
      );
    }).toList();
  }

  void _updateStateListener() async {
    _activeWSId = await storage.getWorkspace();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    storage.changes.addListener(_updateStateListener);
    appState.changes.addListener(_updateStateListener);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loading = true;
      try {
        await appState.fetchWorkspaces();
        _activeWSId = await storage.getWorkspace();
      } on AppStateException catch (e) {
        snack(_scaffKey.currentState, e.message);
      } catch (e) {
        snack(_scaffKey.currentState, 'Something went wrong');
      }
      loading = false;
    });
  }

  @override
  void dispose() {
    storage.changes.removeListener(_updateStateListener);
    appState.changes.removeListener(_updateStateListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'workspaces',
      key: _scaffKey,
      body: RefreshIndicator(
        onRefresh: () {
          print('r e f r e s h');
          return appState.fetchWorkspaces();
        },
        child: Center(
          child: loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : _listOrEmptyMsg(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).accentColor,
        onPressed: () {
          Navigator.of(context).pushNamed('/workspace-edit');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
