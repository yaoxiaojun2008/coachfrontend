import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;
import 'dart:js_util' as js_util;

class ExternalImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const ExternalImageWidget({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simple way to detect if we're running on web
    bool isWeb = () {
      try {
        // Try to access window object which only exists in web
        js_util.getProperty(web.window, 'location');
        return true;
      } catch (e) {
        return false;
      }
    }();

    if (!isWeb) {
      // Fallback for non-web platforms
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.image, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingStatus) {
          if (loadingStatus != null) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return child;
        },
      );
    }

    // Register the element for web
    final String viewID = 'external-image-${DateTime.now().millisecondsSinceEpoch}-${imageUrl.hashCode}';
    
    ui_web.platformViewRegistry.registerViewFactory(viewID, (int viewId) {
      final imageElement = web.document.createElement('img');
      imageElement.setAttribute('src', imageUrl);
      imageElement.setAttribute('style', 
        'width: 100%; height: 100%; object-fit: ${fit?.toString().split('.').last ?? 'cover'}; border-radius: 8px; display: block;'
      );
      
      // Define error handler function
      void errorHandler(web.Event event) {
        // Clear the image source
        imageElement.setAttribute('src', '');
        // Set a background and add an icon
        imageElement.setAttribute('style', 
          'width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background-color: #e0e0e0; border-radius: 8px;'
        );
        // Create and append a fallback element
        final divElement = web.document.createElement('div');
        divElement.setAttribute('style', 'display: flex; align-items: center; justify-content: center; width: 100%; height: 100%;');
        final spanElement = web.document.createElement('span');
        spanElement.setAttribute('style', 'font-size: 24px; color: #9e9e9e;');
        spanElement.text = '📷';
        divElement.append(spanElement);
        imageElement.replaceWith(divElement);
      }
      
      // Add event listener
      imageElement.onAbort.listen((event) => errorHandler(event));
      imageElement.onError.listen((event) => errorHandler(event));
      
      return imageElement;
    });

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: HtmlElementView(
        viewType: viewID,
      ),
    );
  }
}