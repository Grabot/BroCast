//
//  NotificationService.swift
//  BrocastExtension
//
//  Created by Zwaar on 05/04/2025.
//
import UserNotifications
import awesome_notifications_fcm

@available(iOS 10.0, *)
class NotificationService: DartAwesomeServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        super.didReceive(request, withContentHandler: { content in
                    self.bestAttemptContent = (content.mutableCopy() as? UNMutableNotificationContent)

                    guard let bestAttemptContent = self.bestAttemptContent else {
                        return
                    }

                    bestAttemptContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "common_notification_sound.aiff"))

                    contentHandler(bestAttemptContent)
                })
    }
}
