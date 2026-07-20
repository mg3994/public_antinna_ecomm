import 'package:blogger_theme/blogger_theme.dart';

final blog_posts_widget = BWidget(
  id: 'Blog1',
  type: 'Blog',
  locked: true,
  title: 'Blog Posts',
  version: 2,
  isVisible: true,
  children: [
    BWidgetSettings(
      children: [
        BWidgetSetting(name: 'showDateHeader', children: [Text('false')]),
        BWidgetSetting(name: 'style.textcolor', children: [Text('#ffffff')]),
        BWidgetSetting(name: 'showShareButtons', children: [Text('false')]),
        BWidgetSetting(name: 'showCommentLink', children: [Text('true')]),
        BWidgetSetting(name: 'style.urlcolor', children: [Text('#ffffff')]),
        BWidgetSetting(name: 'showAuthor', children: [Text('true')]),
        BWidgetSetting(name: 'style.linkcolor', children: [Text('#ffffff')]),
        BWidgetSetting(name: 'style.unittype', children: [Text('TextAndImage')]),
        BWidgetSetting(name: 'style.bgcolor', children: [Text('#ffffff')]),
        BWidgetSetting(name: 'reactionsLabel', children: []),
        BWidgetSetting(name: 'showAuthorProfile', children: [Text('false')]),
        BWidgetSetting(name: 'style.layout', children: [Text('1x1')]),
        BWidgetSetting(name: 'showLabels', children: [Text('true')]),
        BWidgetSetting(name: 'showLocation', children: [Text('true')]),
        BWidgetSetting(name: 'showTimestamp', children: [Text('true')]),
        BWidgetSetting(name: 'postsPerAd', children: [Text('1')]),
        BWidgetSetting(name: 'showBacklinks', children: [Text('false')]),
        BWidgetSetting(name: 'style.bordercolor', children: [Text('#ffffff')]),
        BWidgetSetting(name: 'showInlineAds', children: [Text('false')]),
        BWidgetSetting(name: 'showReactions', children: [Text('false')]),
      ],
    ),

    BIncludable(
      id: 'postCard',
      varName: 'post',
      children: [
        A(
          attributes: {
            'class': 'card',
            'expr:href': 'data:post.url',
            'expr:id': '"card-" + data:post.id',
          },
          children: [
            Img(
              attributes: {
                'class': 'card-img',
                'expr:data-src': 'data:post.featuredImage ?: "https://via.placeholder.com/400x300?text=Antinna"',
                'loading': 'lazy',
                'src': 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7',
              },
            ),
            Div(
              attributes: {'class': 'card-body'},
              children: [
                Div(
                  attributes: {'class': 'card-badge'},
                  children: [Text('Loading...')],
                ),
                H3(
                  attributes: {'class': 'card-title'},
                  children: [BData(value: 'post.title')],
                ),
                Div(
                  attributes: {'class': 'card-price'},
                  children: [Text('--')],
                ),
              ],
            ),
            XmlComment('Raw JSON-LD for Grid Parser'),
            Div(
              attributes: {'class': 'hidden grid-data'},
              children: [BData(value: 'post.body')],
            ),
          ],
        ),
      ],
    ),

    BIncludable(
      id: 'main',
      varName: 'top',
      children: [
        BIf(
          cond: 'data:view.isHomepage',
          children: [
            BIf(
              cond: 'data:posts and data:posts any (p => p.labels and p.labels any (l => l.name == "featured" or l.name == "popular"))',
              children: [
                H2(
                  attributes: {'class': 'section-title'},
                  children: [Text('Featured Selection')],
                ),
                Div(
                  attributes: {'class': 'grid', 'id': 'featured-grid'},
                  children: [
                    BLoop(
                      values: 'data:posts',
                      varName: 'post',
                      children: [
                        BIf(
                          cond: 'data:post.labels and data:post.labels any (l => l.name == "featured" or l.name == "popular")',
                          children: [
                            BInclude(name: 'postCard', data: 'post'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            H2(
              attributes: {'class': 'section-title'},
              children: [Text('Latest Arrivals')],
            ),
          ],
        ),

        BIf(
          cond: 'data:view.isMultipleItems',
          children: [
            Div(
              attributes: {'class': 'grid', 'id': 'app-grid'},
              children: [
                BLoop(
                  values: 'data:posts',
                  varName: 'post',
                  children: [
                    BInclude(name: 'postCard', data: 'post'),
                  ],
                ),
              ],
            ),
            XmlComment('Pagination'),
            Div(
              attributes: {
                'class': 'blog-pager',
                'style': 'text-align:center; margin-top:40px;'
              },
              children: [
                BIf(
                  cond: 'data:newerPageUrl',
                  children: [
                    A(
                      attributes: {
                        'class': 'v-btn',
                        'expr:href': 'data:newerPageUrl',
                        'style': 'text-decoration:none;'
                      },
                      children: [RawText('&#171; Newer')],
                    ),
                  ],
                ),
                BIf(
                  cond: 'data:olderPageUrl',
                  children: [
                    A(
                      attributes: {
                        'class': 'v-btn',
                        'expr:href': 'data:olderPageUrl',
                        'style': 'text-decoration:none; margin-left:10px;'
                      },
                      children: [RawText('Older &#187;')],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        BElse(),
        BLoop(
          values: 'data:posts',
          varName: 'post',
          children: [
            Div(
              attributes: {'id': 'app-item'},
              children: [
                Div(
                  attributes: {
                    'class': 'breadcrumb',
                    'style': 'margin-bottom:20px; font-size:0.9rem;'
                  },
                  children: [
                    A(
                      attributes: {'expr:href': 'data:blog.homepageUrl'},
                      children: [Text('Home')],
                    ),
                    Text(' / '),
                    BIf(
                      cond: 'data:post.labels',
                      children: [
                        BLoop(
                          values: 'data:post.labels',
                          varName: 'label',
                          index: 'i',
                          children: [
                            A(
                              attributes: {'expr:href': 'data:label.url'},
                              children: [BData(value: 'label.name')],
                            ),
                            BIf(
                              cond: 'data:i < data:post.labels.size - 1',
                              children: [Text(', ')],
                            ),
                          ],
                        ),
                        Text(' / '),
                      ],
                    ),
                    BData(value: 'post.title'),
                  ],
                ),

                Div(
                  attributes: {
                    'class': 'product-layout',
                    'id': 'main-renderer',
                    'style': 'min-height: 400px;'
                  },
                  children: [
                    XmlComment('Initializing State'),
                    Div(
                      attributes: {
                        'id': 'initializing-state',
                        'style': 'padding:40px; text-align:center; grid-column: 1 / -1;'
                      },
                      children: [
                        Div(
                          attributes: {
                            'class': 'v-btn',
                            'style': 'display:inline-block; cursor:default; animation: pulse 1.5s infinite;'
                          },
                          children: [Text('Initializing Data Engine...')],
                        ),
                      ],
                    ),

                    Div(
                      attributes: {
                        'class': 'carousel-container hidden',
                        'id': 'carousel-section'
                      },
                      children: [
                        Div(
                          attributes: {
                            'class': 'carousel',
                            'id': 'main-carousel'
                          },
                          children: [
                            Div(
                              attributes: {
                                'class': 'carousel-inner',
                                'id': 'carousel-inner'
                              },
                            ),
                            Button(
                              attributes: {
                                'class': 'carousel-btn',
                                'onclick': 'prevSlide()',
                                'style': 'left:10px;'
                              },
                              children: [RawText('&#10094;')],
                            ),
                            Button(
                              attributes: {
                                'class': 'carousel-btn',
                                'onclick': 'nextSlide()',
                                'style': 'right:10px;'
                              },
                              children: [RawText('&#10095;')],
                            ),
                          ],
                        ),
                        Div(
                          attributes: {
                            'class': 'h-scroll',
                            'id': 'thumbnail-row',
                            'style': 'margin-top:10px; gap:10px;'
                          },
                        ),
                      ],
                    ),

                    Div(
                      attributes: {
                        'class': 'details-container hidden',
                        'id': 'details-section'
                      },
                      children: [
                        H1(
                          attributes: {'id': 'p-name'},
                          children: [BData(value: 'post.title')],
                        ),
                        Div(
                          attributes: {
                            'id': 'p-sku',
                            'style': 'font-size:0.75rem; color:#888; margin-bottom:10px;'
                          },
                        ),
                        Div(
                          attributes: {'class': 'price', 'id': 'p-price'},
                          children: [Text('--')],
                        ),
                        P(
                          attributes: {
                            'id': 'p-desc',
                            'style': 'color:#666;'
                          },
                        ),
                        Div(
                          attributes: {
                            'class': 'variants',
                            'id': 'p-variants'
                          },
                        ),
                        Div(
                          attributes: {
                            'id': 'p-order-info',
                            'style': 'margin-top:20px; padding:15px; background:#f9f9f9; border-radius:8px; display:none;'
                          },
                          children: [
                            H4(
                              attributes: {'style': 'margin:0 0 10px;'},
                              children: [Text('Order & Delivery Information')],
                            ),
                            Div(attributes: {'id': 'order-info-list', 'style': 'font-size:0.85rem; line-height:1.8;'}),
                          ],
                        ),
                        Div(
                          attributes: {
                            'id': 'p-specs',
                            'style': 'margin-top:20px; display:none;'
                          },
                          children: [
                            H4(
                              attributes: {'style': 'margin:0 0 10px; border-bottom:1px solid #eee; padding-bottom:5px;'},
                              children: [Text('Product Specifications')],
                            ),
                            Div(attributes: {'id': 'specs-list', 'style': 'font-size:0.9rem;'}),
                          ],
                        ),
                        Div(
                          attributes: {
                            'class': 'seller-box',
                            'id': 'p-seller'
                          },
                          children: [
                            H4(
                              attributes: {'style': 'margin:0 0 10px;'},
                              children: [Text('Seller Details')],
                            ),
                            Div(attributes: {'id': 'seller-info'}),
                            Div(
                              attributes: {
                                'style': 'display:flex; align-items:center; gap:10px; flex-wrap:wrap;'
                              },
                              children: [
                                Div(
                                  attributes: {
                                    'class': 'geo-badge',
                                    'id': 'geo-info'
                                  },
                                  children: [
                                    RawText('&#128205; '),
                                    Span(
                                      attributes: {'id': 'geo-text'},
                                      children: [Text('GEO Points Present')],
                                    ),
                                  ],
                                ),
                                A(
                                  attributes: {
                                    'class': 'social-link',
                                    'id': 'maps-link',
                                    'style': 'background:#34495e; display:none;',
                                    'target': '_blank'
                                  },
                                  children: [Text('Open in Maps')],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                Div(
                  attributes: {
                    'id': 'other-services',
                    'style': 'margin-top:50px; display:none;'
                  },
                  children: [
                    H2(
                      attributes: {'style': 'margin-bottom:20px;'},
                      children: [
                        Text('Optional Product-Related Services '),
                        DomComponent(
                          'small',
                          children: [Text('(Additional Charges May Apply)')],
                        ),
                      ],
                    ),
                    Div(
                      attributes: {
                        'class': 'h-scroll',
                        'id': 'other-services-list'
                      },
                    ),
                  ],
                ),
              ],
            ),
            XmlComment('Content for Parser'),
            Div(
              attributes: {
                'class': 'hidden',
                'id': 'post-body-raw',
                'style': 'display: none !important;'
              },
              children: [BData(value: 'post.body')],
            ),
          ],
        ),
      ],
    ),

    BIncludable(
      id: 'aboutPostAuthor',
      children: [
        Div(
          attributes: {'class': 'author-name'},
          children: [
            A(
              attributes: {
                'class': 'g-profile',
                'expr:href': 'data:post.author.profileUrl',
                'rel': 'author',
                'title': 'author profile'
              },
              children: [
                Span(children: [BData(value: 'post.author.name')]),
              ],
            ),
          ],
        ),
        Div(
          children: [
            Span(
              attributes: {'class': 'author-desc'},
              children: [BData(value: 'post.author.aboutMe')],
            ),
          ],
        ),
      ],
    ),
    BIncludable(
      id: 'addComments',
      children: [
        A(
          attributes: {
            'expr:href': 'data:post.commentsUrl',
            'expr:onclick': 'data:post.commentsUrlOnclick'
          },
          children: [
            BMessage(name: 'messages.postAComment'),
          ],
        ),
      ],
    ),
    BIncludable(
      id: 'commentAuthorAvatar',
      children: [
        Div(
          attributes: {'class': 'avatar-image-container'},
          children: [
            Img(
              attributes: {
                'class': 'author-avatar',
                'expr:src': 'data:comment.authorAvatarSrc',
                'height': '35',
                'width': '35'
              },
            ),
          ],
        ),
      ],
    ),
    BIncludable(
      id: 'commentDeleteIcon',
      varName: 'comment',
      children: [
        Span(
          attributes: {'expr:class': '"item-control " + data:comment.adminClass'},
          children: [
            BIf(
              cond: 'data:showCmtPopup',
              children: [
                Div(
                  attributes: {'class': 'goog-toggle-button'},
                  children: [
                    Div(attributes: {'class': 'goog-inline-block comment-action-icon'}),
                  ],
                ),
              ],
            ),
            BElse(),
            A(
              attributes: {
                'class': 'comment-delete',
                'expr:href': 'data:comment.deleteUrl',
                'expr:title': 'data:messages.deleteComment'
              },
              children: [
                Img(attributes: {'src': 'https://resources.blogblog.com/img/icon_delete13.gif'}),
              ],
            ),
          ],
        ),
      ],
    ),
    BIncludable(
      id: 'commentForm',
      varName: 'post',
      children: [
        Div(
          attributes: {'class': 'comment-form'},
          children: [
            A(attributes: {'name': 'comment-form'}),
            H4(
              attributes: {'id': 'comment-post-message'},
              children: [BData(value: 'messages.postAComment')],
            ),
            BIf(
              cond: 'data:this.messages.blogComment != ""',
              children: [
                P(children: [BData(value: 'this.messages.blogComment')]),
              ],
            ),
            BInclude(name: 'commentFormIframeSrc', data: 'post'),
            DomComponent(
              'iframe',
              attributes: {
                'allowtransparency': 'allowtransparency',
                'class': 'blogger-iframe-colorize blogger-comment-from-post',
                'expr:height': 'data:cmtIframeInitialHeight ?: "90px"',
                'frameborder': '0',
                'id': 'comment-editor',
                'name': 'comment-editor',
                'src': '',
                'width': '100%'
              },
            ),
            BData(value: 'post.cmtfpIframe'),
            Script(
              type: 'text/javascript',
              content: "BLOG_CMT_createIframe('\" + data:post.appRpcRelayPath + \"');",
            ),
          ],
        ),
      ],
    ),
    BIncludable(
      id: 'commentFormIframeSrc',
      varName: 'post',
      children: [
        A(attributes: {'expr:href': 'data:post.commentFormIframeSrc', 'id': 'comment-editor-src'}),
      ],
    ),
    BIncludable(
      id: 'commentItem',
      varName: 'comment',
      children: [
        Div(
          attributes: {
            'class': 'comment',
            'expr:id': '"c" + data:comment.id'
          },
          children: [
            BInclude(cond: 'data:blog.enabledCommentProfileImages', name: 'commentAuthorAvatar'),
            Div(
              attributes: {'class': 'comment-block'},
              children: [
                Div(
                  attributes: {'class': 'comment-author'},
                  children: [
                    BIf(
                      cond: 'data:comment.authorUrl',
                      children: [
                        BMessage(
                          name: 'messages.authorSaidWithLink',
                          children: [
                            BParam(exprValue: 'data:comment.author', value: 'authorName'),
                            BParam(exprValue: 'data:comment.authorUrl', value: 'authorUrl'),
                          ],
                        ),
                        BElse(),
                        BMessage(
                          name: 'messages.authorSaid',
                          children: [
                            BParam(exprValue: 'data:comment.author', value: 'authorName'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Div(
                  attributes: {
                    'expr:class': '"comment-body" + (data:comment.isDeleted ? " deleted" : "")'
                  },
                  children: [BData(value: 'comment.body')],
                ),
                Div(
                  attributes: {'class': 'comment-footer'},
                  children: [
                    Span(
                      attributes: {'class': 'comment-timestamp'},
                      children: [
                        A(
                          attributes: {
                            'expr:href': 'data:comment.url',
                            'title': 'comment permalink'
                          },
                          children: [BData(value: 'comment.timestamp')],
                        ),
                        BInclude(data: 'comment', name: 'commentDeleteIcon'),
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
    BIncludable(
      id: 'commentList',
      varName: 'comments',
      children: [
        Div(
          attributes: {'id': 'comments-block'},
          children: [
            BLoop(
              values: 'data:comments',
              varName: 'comment',
              children: [
                BInclude(data: 'comment', name: 'commentItem'),
              ],
            ),
          ],
        ),
      ],
    ),
    BIncludable(
      id: 'commentPicker',
      varName: 'post',
      children: [
        BIf(
          cond: 'data:post.showThreadedComments',
          children: [
            BInclude(name: 'threadedComments', data: 'post'),
          ],
        ),
        BElse(),
        BInclude(name: 'comments', data: 'post'),
      ],
    ),
    BIncludable(
      id: 'comments',
      varName: 'post',
      children: [
        Section(
          attributes: {
            'expr:class': '"comments" + (data:post.embedCommentForm ? " embed" : "")',
            'expr:data-num-comments': 'data:post.numberOfComments',
            'id': 'comments'
          },
          children: [
            A(attributes: {'name': 'comments'}),
            BIf(
              cond: 'data:post.allowComments',
              children: [
                BInclude(name: 'commentsTitle'),
                Div(
                  attributes: {'expr:id': 'data:widget.instanceId + "_comments-block-wrapper"'},
                  children: [
                    BInclude(cond: 'data:post.comments', data: 'post.comments', name: 'commentList'),
                  ],
                ),
                BIf(
                  cond: 'data:post.commentPagingRequired',
                  children: [
                    Div(
                      attributes: {'class': 'paging-control-container'},
                      children: [
                        BIf(
                          cond: 'data:post.hasOlderLinks',
                          children: [
                            A(
                              attributes: {
                                'expr:class': 'data:post.oldLinkClass',
                                'expr:href': 'data:post.oldestLinkUrl'
                              },
                              children: [BData(value: 'messages.oldest')],
                            ),
                            A(
                              attributes: {
                                'expr:class': 'data:post.oldLinkClass',
                                'expr:href': 'data:post.olderLinkUrl'
                              },
                              children: [BData(value: 'messages.older')],
                            ),
                          ],
                        ),
                        Span(
                          attributes: {'class': 'comment-range-text'},
                          children: [BData(value: 'post.commentRangeText')],
                        ),
                        BIf(
                          cond: 'data:post.hasNewerLinks',
                          children: [
                            A(
                              attributes: {
                                'expr:class': 'data:post.newLinkClass',
                                'expr:href': 'data:post.newerLinkUrl'
                              },
                              children: [BData(value: 'messages.newer')],
                            ),
                            A(
                              attributes: {
                                'expr:class': 'data:post.newLinkClass',
                                'expr:href': 'data:post.newestLinkUrl'
                              },
                              children: [BData(value: 'messages.newest')],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Div(
                  attributes: {'class': 'footer'},
                  children: [
                    BIf(
                      cond: 'data:post.embedCommentForm',
                      children: [
                        BIf(
                          cond: 'data:post.allowNewComments',
                          children: [
                            BInclude(data: 'post', name: 'commentForm'),
                          ],
                        ),
                        BElse(),
                        BData(value: 'post.noNewCommentsText'),
                      ],
                    ),
                    BElse(),
                    BIf(
                      cond: 'data:post.allowComments',
                      children: [
                        BInclude(data: 'post', name: 'addComments'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            BIf(
              cond: 'data:showCmtPopup',
              children: [
                Div(
                  attributes: {'id': 'comment-popup'},
                  children: [
                    DomComponent(
                      'iframe',
                      attributes: {
                        'allowtransparency': 'allowtransparency',
                        'frameborder': '0',
                        'id': 'comment-actions',
                        'name': 'comment-actions',
                        'scrolling': 'no'
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    BIncludable(
      id: 'commentsTitle',
      children: [
        H3(
          attributes: {'class': 'title'},
          children: [BData(value: 'messages.comments')],
        ),
      ],
    ),
    BIncludable(
      id: 'threadedCommentForm',
      varName: 'post',
      children: [
        Div(
          attributes: {'class': 'comment-form'},
          children: [
            A(attributes: {'name': 'comment-form'}),
            H4(
              attributes: {'id': 'comment-post-message'},
              children: [BData(value: 'messages.postAComment')],
            ),
            BIf(
              cond: 'data:this.messages.blogComment != ""',
              children: [
                P(children: [BData(value: 'this.messages.blogComment')]),
              ],
            ),
            BInclude(name: 'commentFormIframeSrc', data: 'post'),
            DomComponent(
              'iframe',
              attributes: {
                'allowtransparency': 'allowtransparency',
                'class': 'blogger-iframe-colorize blogger-comment-from-post',
                'expr:height': 'data:cmtIframeInitialHeight ?: "90px"',
                'frameborder': '0',
                'id': 'comment-editor',
                'name': 'comment-editor',
                'src': '',
                'width': '100%'
              },
            ),
            BData(value: 'post.cmtfpIframe'),
            Script(
              type: 'text/javascript',
              content: "BLOG_CMT_createIframe('\" + data:post.appRpcRelayPath + \"');",
            ),
          ],
        ),
      ],
    ),
    BIncludable(
      id: 'threadedCommentJs',
      varName: 'post',
      children: [
        DomComponent(
          'script',
          attributes: {
            'async': 'async',
            'expr:src': 'data:post.commentSrc',
            'type': 'text/javascript'
          },
        ),
        BTemplateScript(name: 'threaded_comments', version: '1.0.0'),
        Script(
          type: 'text/javascript',
          content: "blogger.widgets.blog.initThreadedComments(\" + data:post.commentJso + \", \" + data:post.commentMsgs + \", \" + data:post.commentConfig + \");",
        ),
      ],
    ),
    BIncludable(
      id: 'threadedComments',
      varName: 'post',
      children: [
        Section(
          attributes: {
            'class': 'comments threaded',
            'expr:data-embed': 'data:post.embedCommentForm',
            'expr:data-num-comments': 'data:post.numberOfComments',
            'id': 'comments'
          },
          children: [
            A(attributes: {'name': 'comments'}),
            BInclude(name: 'commentsTitle'),
            Div(
              attributes: {'class': 'comments-content'},
              children: [
                BIf(
                  cond: 'data:post.embedCommentForm',
                  children: [
                    BInclude(data: 'post', name: 'threadedCommentJs'),
                  ],
                ),
                Div(
                  attributes: {'id': 'comment-holder'},
                  children: [BData(value: 'post.commentHtml')],
                ),
              ],
            ),
            P(
              attributes: {'class': 'comment-footer'},
              children: [
                BIf(
                  cond: 'data:post.allowNewComments',
                  children: [
                    BInclude(data: 'post', name: 'threadedCommentForm'),
                  ],
                ),
                BElse(),
                BData(value: 'post.noNewCommentsText'),
                BIf(
                  cond: 'data:post.showManageComments',
                  children: [
                    BInclude(name: 'manageComments', data: 'post'),
                  ],
                ),
              ],
            ),
            BIf(
              cond: 'data:showCmtPopup',
              children: [
                Div(
                  attributes: {'id': 'comment-popup'},
                  children: [
                    DomComponent(
                      'iframe',
                      attributes: {
                        'allowtransparency': 'allowtransparency',
                        'frameborder': '0',
                        'id': 'comment-actions',
                        'name': 'comment-actions',
                        'scrolling': 'no'
                      },
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
);
