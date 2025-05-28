import 'package:brocast/utils/storage.dart';

import '../objects/bro.dart';
import '../objects/broup.dart';
import '../objects/me.dart';
import '../services/auth/v1_4/auth_service_social.dart';

broUpdatedBromotion(Me me, int broId, String newBromotion) async {
  for (Broup broup in me.broups) {
    for (int broupBroId in broup.broIds) {
      if (broupBroId == broId) {
        bool foundBro = false;
        for (Bro bro in broup.broupBros) {
          if (bro.id == broId) {
            foundBro = true;
            bro.bromotion = newBromotion;
            if (broup.private) {
              Storage().updateBro(bro);
              AuthServiceSocial().broupBrosRetrieved(broup.broupId, [broId]);
            }
          }
        }
        if (!foundBro) {
          Bro? bro = await AuthServiceSocial().retrieveBro(broId);
          if (bro != null) {
            Storage().addBro(bro);
          }
        }
      }
    }
  }
}

broUpdatedBroname(Me me, int broId, String newBroname) async {
  for (Broup broup in me.broups) {
    for (int broupBroId in broup.broIds) {
      if (broupBroId == broId) {
        bool foundBro = false;
        for (Bro bro in broup.broupBros) {
          if (bro.id == broId) {
            foundBro = true;
            bro.broName = newBroname;
            if (broup.private) {
              Storage().updateBro(bro);
              AuthServiceSocial().broupBrosRetrieved(broup.broupId, [broId]);
            }
          }
        }
        if (!foundBro) {
          Bro? bro = await AuthServiceSocial().retrieveBro(broId);
          if (bro != null) {
            Storage().addBro(bro);
          }
        }
      }
    }
  }
}
