// <!-- Account Settings Modal Dialog -->
import 'package:blogger_theme/blogger_theme.dart';

final account_settings_modal_backdrop = Div(
  attributes: {
    "class": "settings-modal-backdrop",
    "id": "account-settings-modal-backdrop",
  },
  children: [
    Div(
      attributes: {"class": "settings-modal"},
      children: [
        Div(
          attributes: {"class": "settings-modal-header"},
          children: [
            Span(
              attributes: {"class": "settings-modal-title"},
              children: [Text("Session Settings")],
            ),
            Button(
              attributes: {
                "class": "settings-modal-close",
                "onclick": "closeSettingsModal()",
                "aria-label": "Close settings",
              },
              children: [Text("×")],
            ),
          ],
        ),
        Div(
          attributes: {"class": "settings-modal-body"},
          children: [
            Div(
              attributes: {"class": "settings-user-info"},
              children: [
                Img(
                  attributes: {
                    "class": "settings-avatar",
                    "id": "modal-user-avatar",
                    "src":
                        "https://www.gravatar.com/avatar/00000000000000000000000000000000",
                    "alt": "User Avatar",
                  },
                ),
                Span(
                  attributes: {
                    "class": "settings-name",
                    "id": "modal-user-name",
                  },
                  children: [Text("Guest User")],
                ),
                Span(
                  attributes: {
                    "class": "settings-email",
                    "id": "modal-user-email",
                  },
                  children: [Text("email address")],
                ),
                Div(
                  attributes: {
                    "class": "settings-phone ui-hidden",
                    "id": "modal-user-phone-container",
                  },
                  children: [
                    //
                    Svg(
                      width: "14",
                      height: "14",
                      viewBox: "0 0 24 24",
                      fill: "none",
                      stroke: "currentColor",
                      strokeWidth: "2.5",
                      strokeLinecap: "round",
                      strokeLinejoin: "round",
                      children: [
                        Path(
                          d: "M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z",
                        ),
                      ],
                    ),
                    Span(attributes: {"id": "modal-user-phone"}),
                  ],
                ),
                // id="modal-user-unlink-container" class="ui-hidden" style="width: 100%;"
                Div(
                  attributes: {
                    'id': "modal-user-unlink-container",
                    'class': "ui-hidden",
                    'style': "width: 100%;",
                  },
                ),
              ],
            ),

            //
            Div(
              attributes: {"class": "settings-detail-section"},
              children: [
                Span(
                  attributes: {"class": "settings-detail-label"},
                  children: [Text("Account USER ID")],
                ),
                Div(
                  attributes: {"class": "settings-uid-box"},
                  children: [
                    Span(
                      attributes: {
                        "class": "settings-uid-value",
                        "id": "modal-user-uid",
                      },
                      children: [Text("N/A")],
                    ),
                    Button(
                      attributes: {
                        "class": "btn-copy-settings-uid",
                        "id": "modal-copy-uid-btn",
                        "title": "Copy UID",
                      },
                      children: [
                        Svg(
                          width: "14",
                          height: "14",
                          viewBox: "0 0 24 24",
                          fill: "none",
                          stroke: "currentColor",
                          strokeWidth: "2.5",
                          strokeLinecap: "round",
                          strokeLinejoin: "round",
                          children: [
                            Rect(
                              x: "9",
                              y: "9",
                              width: "13",
                              height: "13",
                              rx: "2",
                              ry: "2",
                            ),
                            Path(
                              d: "M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        //
        //
        //     <div "class":"settings-modal-footer">
        //       <button class="btn-modal-logout" id="modal-signout-btn">
        //         <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        //           <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
        //           <polyline points="16 17 21 12 16 7"></polyline>
        //           <line x1="21" y1="12" x2="9" y2="12"></line>
        //         </svg>
        //         <span>Logout Session</span>
        //       </button>
        //     </div>
        Div(
          attributes: {"class": "settings-modal-footer"},
          children: [
            Button(
              attributes: {
                "class": "btn-modal-logout",
                "id": "modal-signout-btn",
              },
              children: [
                Svg(
                  width: "16",
                  height: "16",
                  viewBox: "0 0 24 24",
                  fill: "none",
                  stroke: "currentColor",
                  strokeWidth: "2",
                  strokeLinecap: "round",
                  strokeLinejoin: "round",
                  children: [
                    Path(d: "M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"),
                    Polyline(points: "16 17 21 12 16 7"),
                    Line(x1: "21", y1: "12", x2: "9", y2: "12"),
                  ],
                ),
                //  <span>Logout Session</span>
                Span(children: [Text("Logout Session")]),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
// <div class="settings-modal-backdrop" id="account-settings-modal-backdrop">
//   <div class="settings-modal">
//     <div class="settings-modal-header">
//       <span class="settings-modal-title">Account Settings</span>
//       <button class="settings-modal-close" onclick="closeSettingsModal()" aria-label="Close settings">×</button>
//     </div>
//     <div class="settings-modal-body">
//       <div class="settings-user-info">
//         <img class="settings-avatar" id="modal-user-avatar" src="https://www.gravatar.com/avatar/00000000000000000000000000000000" alt="User Avatar" />
//         <span class="settings-name" id="modal-user-name">Guest User</span>
//         <span class="settings-email" id="modal-user-email">guest@example.com</span>
//         <div class="settings-phone ui-hidden" id="modal-user-phone-container">
//           <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
//             <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
//           </svg>
//           <span id="modal-user-phone"></span>
//         </div>
//       </div>
//       <div class="settings-detail-section">
//         <span class="settings-detail-label">Firebase Account UID</span>
//         <div class="settings-uid-box">
//           <span class="settings-uid-value" id="modal-user-uid">N/A</span>
//           <button class="btn-copy-settings-uid" id="modal-copy-uid-btn" title="Copy UID">
//             <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
//               <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
//               <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
//             </svg>
//           </button>
//         </div>
//       </div>
//     </div>
//     <div class="settings-modal-footer">
//       <button class="btn-modal-logout" id="modal-signout-btn">
//         <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
//           <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
//           <polyline points="16 17 21 12 16 7"></polyline>
//           <line x1="21" y1="12" x2="9" y2="12"></line>
//         </svg>
//         <span>Logout Session</span>
//       </button>
//     </div>
//   </div>
// </div>
