import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class LimitedTimeOptionItem extends StatelessWidget {
  final String text;
  final String labelText;
  final String badgeImageUrl;
  final bool isSelected;
  final bool isInStock;
  final VoidCallback? onTap;

  const LimitedTimeOptionItem({
    super.key,
    required this.text,
    required this.labelText,
    this.badgeImageUrl = '',
    this.isSelected = false,
    this.isInStock = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 字体和颜色基于截图估算，实际项目中应使用统一的Theme或Color常量
    Color borderColor =
        isSelected ? const Color(0xFFFF5CE5) : const Color(0xFFDDAF88); // 金棕色边框
    Color bgColor =
        isSelected ? const Color(0xFFFEEAFE) : Colors.white; // 金棕色背景
    const Color labelColor = Color(0xFFFF50D6); // 粉色标签文案
    Color textColor =
        isInStock ? const Color(0xFF0B0B13) : const Color(0xFFECD7CA);

    return GestureDetector(
        onTap: onTap,
        child: IntrinsicWidth(
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: borderColor,
                width: 1.0,
              ),
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // 主体容器（边框随整体宽度自适应）
                Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    constraints: BoxConstraints(minWidth: 64),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        decoration: isInStock
                            ? TextDecoration.none
                            : TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ),

                //  顶部标签（参与宽度计算，视觉上压在顶部边框上）
                if (labelText.isNotEmpty || badgeImageUrl.isNotEmpty)
                  Transform.translate(
                    offset: Offset(0, -10),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      color: bgColor, // 用背景色遮挡边框，形成“贴边”效果
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // if (badgeImageUrl.isNotEmpty)
                          //   ImageWidget.url(
                          //     ImageUrl.imageResize(badgeImageUrl,
                          //         width: 10.w, height: 10.w),
                          //     width: 10.w,
                          //     height: 16.w,
                          //     fit: BoxFit.contain,
                          //   ),
                          // if (badgeImageUrl.isNotEmpty && labelText.isNotEmpty)
                          //   Gap(4.w),
                          Text(
                            labelText,
                            style: const TextStyle(
                              color: labelColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ));
  }
}
