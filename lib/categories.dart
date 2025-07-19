import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:odo_mobile_v2/providers/auth.dart';
import 'package:odo_mobile_v2/providers/cart.dart';
import 'package:odo_mobile_v2/providers/banner.dart';
import 'package:odo_mobile_v2/providers/categories_provider.dart';
import 'package:provider/provider.dart';
import 'package:store_redirect/store_redirect.dart';


import 'PlatformDialog.dart';
import 'cartBadge.dart';
import 'bannerOverlay.dart';

class Categories extends StatefulWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  bool _isFirstTime = true;
  bool _isLoading = true;

  @override
void didChangeDependencies() {
  super.didChangeDependencies();

  if (_isFirstTime) {
    _initializeData();
    _isFirstTime = false;
  }
}

Future<void> _initializeData() async {
  try {
    await doAuthStuff();
    if (!mounted) return;

    await Provider.of<CategoriesProvider>(context, listen: false)
        .fetchBrandsFromDB(isBulandshehar: decideOnCoke());
    if (!mounted) return;

    var distributor = Provider.of<AuthProvider>(context, listen: false).loggedInDistributor;
     var member = distributor;
    var area = Provider.of<AuthProvider>(context, listen: false).loggedInArea;
     var memberKey = Provider.of<AuthProvider>(context, listen: false)
        .activeDistributorKey;

    await Provider.of<CartProvider>(context, listen: false)
        .fetchCartFromDB(member, memberKey);
    if (!mounted) return;

    await Provider.of<BannerProvider>(context, listen: false).fetchBannersFromDB();
    if (!mounted) return;

    var bannerList = Provider.of<BannerProvider>(context, listen: false).banners;

    if (bannerList.isNotEmpty) {
      // Preload all banner images
      await Future.wait(bannerList.map((banner) async {
        await precacheImage(NetworkImage(banner.imageUrl), context);
      }));

      // After preload, show overlay banners
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          barrierDismissible: false,
          pageBuilder: (_, __, ___) => BannerOverlay(
            bannerList: bannerList,
            onComplete: () {
              setState(() {
                _isLoading = false;
              });
            },
          ),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }

    _checkForAppUpdate();

    print("FETCH COMPLETE!");
  } catch (error) {
    setState(() {
      _isLoading = false;
    });
    showErrorDialog(error.toString());
    print("Error during initialization: $error");
  }
}



  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


  void _checkForAppUpdate() async {
  final newVersion = NewVersionPlus(
    androidId: 'com.production.ODO',
  );

  try {
    final status = await newVersion.getVersionStatus();

    if (status != null) {
      final localVersion = status.localVersion;
      final storeVersion = status.storeVersion;

      if (localVersion != storeVersion) {
        _showUpdateDialog(storeVersion);
      }
    }
  } catch (e) {
    print('Update check failed: $e');
  }
}

void showErrorDialog(String error) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('Error on initialization'),
      content: Text(
        error
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

  void _showUpdateDialog(String latestVersion) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('Update Available'),
      content: Text(
        'A new version ($latestVersion) is available on the Play Store. Please update for the best experience.',
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Later'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            StoreRedirect.redirect(androidAppId: 'com.production.ODO');
            Navigator.pop(context);
          },
          child: const Text('Update'),
        ),
      ],
    ),
  );
}



  bool decideOnCoke()
  {
    var area = Provider.of<AuthProvider>(context,
                                        listen: false)
                                    .loggedInArea;
    if(area.toString().trim().toLowerCase() == "bulandshehar")
    {
      return true;
    }
    return false;
  }

  Future<void> doAuthStuff() async {
    var authObject = Provider.of<AuthProvider>(context, listen: false);
    await authObject.loadLoggedInDistributorData();
  }

  moveToCart(BuildContext context) {
    Navigator.of(context).pushNamed("/cart");
  }

  moveToItems(String brandId, String brandName) {
    Provider.of<CategoriesProvider>(context, listen: false).activeBrandKey =
        brandId;
    Provider.of<CategoriesProvider>(context, listen: false).activeBrandName =
        brandName;

    Navigator.of(context).pushNamed('/items');
  }

  showLogoutBox(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => PlatformDialog(
            title: "LOGOUT?",
            content: "By Clicking OK , you will be logged out",
            callBack: logout));
  }

  Future<void> logout() async {
    Provider.of<CartProvider>(context, listen: false)
        .clearCart(); //taaki next login se mix na hon same phone me.
    await Provider.of<AuthProvider>(context, listen: false).logout();

    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    var brandsData = Provider.of<CategoriesProvider>(context).brands;
    var loggedInDistributor =
        Provider.of<AuthProvider>(context).loggedInDistributor;
    
   return PopScope(
  canPop: false,
  onPopInvoked: (didPop) async {
    if (!didPop) {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Exit App"),
          content: const Text("Do you want to exit the app?"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white, // For text and icon color
        ),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              style: TextButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white, // For text and icon color
        ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("OK"),
            ),
          ],
        ),
      );

      if (shouldExit == true) {
        SystemNavigator.pop(); // Exit the app
      }
    }
  },
    child : SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: <Widget>[ 
            Container(
              padding: const EdgeInsets.all(10.0),
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  loggedInDistributor != 'null'
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          color: Colors.white,
                          onPressed: () {
                            showLogoutBox(context);
                          },
                        )
                      : Container(),
                  SizedBox(
                    width: 150.0,
                    child: loggedInDistributor != 'null'
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.account_circle),
                                color: Colors.white,
                                iconSize: 30,
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/profile');
                                },
                              ),
                              Consumer<CartProvider>(
                                builder: (_, cart, ch) =>  CartBadge(
                                  value: cart.itemCount.toString(),
                                  color: Colors.red,
                                  child: ch!,
                                ),
                                child: 
                                IconButton(
                                  onPressed: () {
                                    moveToCart(context);
                                  },
                                  icon: const Icon(
                                    Icons.shopping_cart,
                                    color: Colors.white,
                                  ),
                                  iconSize: 30,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5.0),
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        loggedInDistributor != 'null'
                            ? "WELCOME $loggedInDistributor"
                            : "WELCOME GUEST",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "ODO BRANDS",
                        style: TextStyle(
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(2, 2),
                              blurRadius: 1,
                            ),
                          ],
                          fontWeight: FontWeight.bold,
                          fontSize: 30.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(75.0),
                  ),
                ),
                child: _isLoading
                    ? const Center(
                        child: SpinKitPulse(
                          color: Color(0xffDD0E1C),
                          size: 50.0,
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(20.0),
                        itemCount: brandsData.length,
                        itemBuilder: (ctx, i) => Stack(
                          alignment: AlignmentDirectional.bottomStart,
                          children: [
                            GestureDetector(
                              onTap: () {
                                 moveToItems(brandsData[i].id,
                                    brandsData[i].brandName);
                              },
                              child: SizedBox(
                                height: 400,
                                width: double.infinity,
                                child: Card(
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  elevation: 15,
                                  child: Stack(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: CachedNetworkImage(
                                          imageUrl: brandsData[i].imageUrl,
                                          fit: BoxFit.fitWidth,
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              const SpinKitPulse(
                                            color: Color(0xffdd0e1c),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 2.0, sigmaY: 2.0),
                                          child: Container(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                 brandsData[i]
                                                    .brandName
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 25.0,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.white,
                                                      offset: Offset(2, 2),
                                                      blurRadius: 10,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3 / 2,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
