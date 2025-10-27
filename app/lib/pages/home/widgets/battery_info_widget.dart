import 'package:flutter/material.dart';
import 'package:omi/backend/preferences.dart';
import 'package:omi/pages/capture/connect.dart';
import 'package:omi/pages/home/device.dart';
import 'package:omi/providers/device_provider.dart';
import 'package:omi/providers/home_provider.dart';
import 'package:omi/utils/analytics/mixpanel.dart';
import 'package:omi/utils/other/temp.dart';
import 'package:omi/utils/styles.dart';
import 'package:provider/provider.dart';

class BatteryInfoWidget extends StatelessWidget {
  const BatteryInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<HomeProvider, bool>(
      selector: (context, state) => state.selectedIndex == 0,
      builder: (context, isMemoriesPage, child) {
        return Consumer<DeviceProvider>(
          builder: (context, deviceProvider, child) {
            if (deviceProvider.connectedDevice != null) {
              return GestureDetector(
                onTap: deviceProvider.connectedDevice == null
                    ? null
                    : () {
                        routeToPage(
                          context,
                          const ConnectedDevice(),
                        );
                        MixpanelManager().batteryIndicatorClicked();
                      },
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(186, 236, 243, 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(width: 1, color: Colors.white)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          "Connected",
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        if (deviceProvider.batteryLevel > 0) ...[
                          const SizedBox(width: 8.0),
                          Text(
                            '${deviceProvider.batteryLevel.toString()}%',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    )),
              );
            } else if (SharedPreferencesUtil().btDevice.id.isNotEmpty) {
              // Device is paired but disconnected
              return GestureDetector(
                onTap: () async {
                  await routeToPage(context, const ConnectedDevice());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 1, color: Colors.white),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        "Disconnected",
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return GestureDetector(
                onTap: () async {
                  if (SharedPreferencesUtil().btDevice.id.isEmpty) {
                    routeToPage(context, const ConnectDevicePage());
                    MixpanelManager().connectFriendClicked();
                  } else {
                    await routeToPage(context, const ConnectedDevice());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(186, 236, 243, 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(width: 1, color: Colors.white)),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fiber_smart_record_outlined,
                        color: Colors.green,
                        size: MediaQuery.sizeOf(context).width * 0.05,
                      ),
                      isMemoriesPage ? const SizedBox(width: 8) : const SizedBox.shrink(),
                      deviceProvider.isConnecting && isMemoriesPage
                          ? Text(
                              "Searching",
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            )
                          : isMemoriesPage
                              ? Text(
                                  "Connect Device",
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                )
                              : const SizedBox.shrink(),
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
