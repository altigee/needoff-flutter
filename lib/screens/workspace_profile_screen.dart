import 'package:flutter/material.dart';
import 'package:needoff/app_state.dart';
import 'package:needoff/models/workspace.dart' show Workspace;
import 'package:needoff/parts/app_scaffold.dart';
import 'package:needoff/services/workspace.dart' as workspaceServ;
import 'package:needoff/utils/ui.dart';
import 'package:needoff/parts/workspace_profile.dart'
    show WorkspaceInfoView, WorkspaceInvitationsView, openAddMemberDialog;

class WorkspaceProfileScreen extends StatefulWidget {
  @override
  _WorkspaceProfileScreenState createState() => _WorkspaceProfileScreenState();
}

class _WorkspaceProfileScreenState extends State<WorkspaceProfileScreen>
    with SingleTickerProviderStateMixin {
  GlobalKey _scaffKey = GlobalKey<ScaffoldState>();
  TabController _tabCtrl;
  Map _wsData;
  int _wsId;
  Workspace _workspace;
  bool _isOwner = false;
  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(vsync: this, length: 3, initialIndex: 0);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Map args = ModalRoute.of(context).settings.arguments;
      if (args != null && (_wsId = Map.from(args)['id']) != null) {
        loadWorkspace().whenComplete(() {
          setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future loadWorkspace() {
    return workspaceServ.fetchWorkspace(_wsId).then((res) {
      if (res.hasErrors || res.data == null) {
        snack(_scaffKey.currentState, 'Failed to load workspace data.');
      } else {
        print(res.data);
        _wsData = res.data;
        _workspace = Workspace.fromJson(
            _wsData['info'], _wsData['invitations'], _wsData['owner']);
        _isOwner = _workspace.owner?.id == appState.profile.id;
        setState(() {});
      }
    });
  }

  updateWorkspace({
    id,
    name,
    description,
  }) {}

  removeInvitation({String email, int workspaceId}) async {
    try {
      var res = await workspaceServ.removeMember(email, workspaceId);
      if (res.hasErrors) {
        snack(_scaffKey.currentState, 'Failed to remove invitation.');
      }
      await loadWorkspace();
    } catch (e) {
      snack(_scaffKey.currentState, 'Something went wrong :(');
    }
  }

  _buildFAB() {
    Widget fab;
    switch (_tabCtrl.index) {
      case 1:
        fab = FloatingActionButton(
          backgroundColor: Theme.of(context).accentColor,
          onPressed: () {
            _handleAddMember(context);
          },
          child: Icon(Icons.add),
        );
        break;
      case 2:
        fab = FloatingActionButton(
          backgroundColor: Theme.of(context).accentColor,
          onPressed: () {
            _handleAddCalendar(context);
          },
          child: Icon(Icons.add),
        );
        break;
      default:
    }
    return fab;
  }

  _handleAddMember(BuildContext ctx) async {
    print('OPEN ADD MEMBER DIALOG');
    Map memberData = await openAddMemberDialog(ctx);
    if (memberData != null) {
      try {
        var res = await workspaceServ.addMember(
            memberData['email'], memberData['startDate'], _workspace.id);
        if (res.hasErrors || res.data == null) {
          snack(_scaffKey.currentState, 'Failed to invite new member.');
        }
        await loadWorkspace();
      } catch (e) {
        snack(_scaffKey.currentState, 'Something went wrong :(');
      }
    }
  }

  _handleAddCalendar(BuildContext ctx) {
    print('OPEN ADD CALENDAR DIALOG');
  }

  @override
  Widget build(BuildContext context) {
    var tabs = <Widget>[
      Tab(
        icon: Icon(Icons.info),
      ),
      Tab(
        icon: Icon(Icons.people),
      ),
      Tab(
        icon: Icon(Icons.date_range),
      ),
    ];
    return AppScaffold(
      'workspace',
      key: _scaffKey,
      tabBar: TabBar(
        tabs: tabs,
        indicatorColor: Colors.white,
        controller: _tabCtrl,
      ),
      body: _workspace != null
          ? TabBarView(
              controller: _tabCtrl,
              children: <Widget>[
                WorkspaceInfoView(_workspace,
                    handleUpdateCallback: _isOwner ? updateWorkspace : null,
                    editable: _isOwner),
                WorkspaceInvitationsView(_workspace,
                    removeCallback: removeInvitation),
                Center(
                  child: Text('workspace holidays.'),
                ),
              ],
            )
          : Center(
              child: Text('No data.'),
            ),
      floatingActionButton: _buildFAB(),
    );
  }
}