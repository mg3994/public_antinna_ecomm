import 'package:blogger_theme/blogger_theme.dart';

final cart_modal_backdrop = Div(
  attributes: {
    'class': 'cart-backdrop',
    'id': 'cart-modal-backdrop',
    'onclick': 'window.CartRenderer.hideModal()',
  },
);

final cart_drawer = Div(
  attributes: {
    'class': 'cart-drawer',
    'id': 'cart-drawer',
  },
  children: [
    Div(
      attributes: {'class': 'cart-header'},
      children: [
        H3(
          attributes: {'style': 'margin:0;'},
          children: [Text('Shopping Bag')],
        ),
        Button(
          attributes: {
            'class': 'qty-btn',
            'onclick': 'window.CartRenderer.hideModal()',
            'style': 'border:none; font-size:1.5rem;',
          },
          children: [RawText('&#215;')],
        ),
      ],
    ),
    Div(
      attributes: {
        'class': 'cart-body',
        'id': 'cart-items-list',
      },
    ),
    Div(
      attributes: {'class': 'cart-footer'},
      children: [
        Div(
          attributes: {
            'style': 'display:flex; justify-content:space-between; font-weight:900; font-size:1.2rem; margin-bottom:20px;'
          },
          children: [
            Span(children: [Text('Total')]),
            Span(
              attributes: {'id': 'cart-total-price'},
              children: [Text('--')],
            ),
          ],
        ),
        Button(
          attributes: {
            'class': 'v-btn active',
            'id': 'cart-confirm-btn',
            'onclick': 'window.CartManager.placeOrder()', // or whatever is used
            'style': 'width:100%; padding:18px; font-size:1.1rem; border-radius:12px;',
          },
          children: [Text('Confirm Order')],
        ),
      ],
    ),
  ],
);

final cart_fab_container = Div(
  attributes: {'id': 'cart-fab-container'},
);

final loc_modal_backdrop = Div(
  attributes: {
    'class': 'modal-backdrop',
    'id': 'loc-modal-backdrop',
    'onclick': 'if(event.target===this) window.LocationRenderer.hideModal()',
  },
  children: [
    Div(
      attributes: {'class': 'modal-content'},
      children: [
        Div(
          attributes: {'class': 'modal-header'},
          children: [
            H3(children: [Text('Select Location')]),
            P(children: [Text('This helps us show products and services available in your area.')]),
          ],
        ),
        Button(
          attributes: {
            'class': 'loc-btn',
            'onclick': 'window.LocationRenderer.handleRequestLocation()',
          },
          children: [
            Span(children: [RawText('🎯')]),
            Text(' Detect My Location'),
          ],
        ),
        Div(
          attributes: {'class': 'modal-divider'},
          children: [
            Span(children: [Text('OR')]),
          ],
        ),
        Div(
          attributes: {'class': 'pin-field'},
          children: [
            Input(
              attributes: {
                'id': 'modal-pin-input',
                'maxlength': '6',
                'placeholder': 'Enter PIN Code',
                'type': 'text',
              },
            ),
            Button(
              attributes: {
                'onclick': 'window.LocationRenderer.handleSetPin()',
              },
              children: [Text('Apply')],
            ),
          ],
        ),
      ],
    ),
  ],
);
