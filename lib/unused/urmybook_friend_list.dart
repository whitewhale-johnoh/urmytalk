import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:urmy_dev_client_v2/Friend_List/urmybook_concord_index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/providers/providers.dart';



class UrMyFriendListPage extends StatefulWidget {
  //const UrMyRegisterPage({Key key}) : super(key: key);

  @override
  _FriendListPageState createState() => _FriendListPageState();
}

class _FriendListPageState extends State<UrMyFriendListPage> {
  static const String routeName = '/friendlist';
  Iterable<Contact> _contacts;

  @override
  void initState() {
    super.initState();
    context.read(friendProvider).refreshContacts();
  }

  Widget buildBody(FriendState friendState) {
    return Container (

    );
    /*_contacts != null ?
        ListView.builder(itemCount: _contacts.length, itemBuilder: _buildRow) :
        Center(child: CircularProgressIndicator());*/

  }

    @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: new AppBar(
        title: new Text('Friend List'),
      ),
      body: ProviderListener<FriendState>(
        provider: friendStateProvider,
        onChange: (context, state) {
          if (state.error != null && state.error.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text(state.error),
                );
              },
            );
          }
        },
        child: Consumer(
          builder: (context, watch, child) {
            return buildBody(
              watch(friendStateProvider),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, int i) {
    Contact c = _contacts.elementAt(i);
    return ListTile(
      leading : (c.avatar != null && c.avatar.length >0)
          ? CircleAvatar(backgroundImage: MemoryImage(c.avatar))
          : CircleAvatar(child: Text(c.initials())),
      title : Text(c.displayName ?? ""),
      onTap: () => Navigator.pushNamed(context, ConcordIndexPage.routeName, arguments: c),

    );
  }


}


