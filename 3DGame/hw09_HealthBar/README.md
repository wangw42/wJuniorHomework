## 使用说明

* 分别使用 IMGUI 和 UGUI 实现，对应视频也在该目录下
* 新建Unity3d项目，使用该目录下的Assets覆盖项目中的Assets后，reload即可。对应的Scenes可以直接展示效果，无需重新拉预制。
  * IMGUI.unity
  * UGUI.unity
* 对应的预制在[./Assets/Prefabs](./Assets/Prefabs)
  * HealthBar_IMGUI.prefab
  * UGUI_HealthBar.prefab

## 两种方法的优缺点

### IMGUI的优缺点

- 优点：
  - 使用和维护都很方便
  - IMGUI 的存在符合游戏编程的传统
  - 在修改模型，渲染模型这样的经典游戏循环编程模式中，在渲染阶段之后，绘制 UI 界面无可挑剔
  - 这样的编程既避免了 UI 元素保持在屏幕最前端，又有最佳的执行效率，一切控制掌握在程序员手中
- 缺点：
  - 传统代码驱动的 UI 面临效率低下
  - 配置不够灵活，实现运动、动画等比较麻烦，难以调试等



### UGUI的优缺点

优点

* 所见即所得设计工具，设计师也能参与程序开发，可以比较方便的修改其属性或者其他操作

* 支持多模式、多摄像机渲染
* UI 元素与游戏场景融为一体的交互
* 面向对象的编程

缺点：

* 使用比较繁琐、对不同的功能需要提供不同的canvas，并单独配置



## 预制的使用方法

对应的预制在[./Assets/Prefabs](./Assets/Prefabs)

* HealthBar_IMGUI.prefab 直接拉上去即可
* UGUI_HealthBar.prefab 需要额外建一个plane，防止角色掉落，然后再拉上去即可运行

