# WxAssistant

微信逆向开发

此示例仅用于学习逆向开发技术，学习逆向的步骤和思路，不得用于任何商业用途，请支持正版版权。
使用非官方客户端会导致微信账号不安全、限制使用、甚至封号的风险，请谨慎使用。

目前功能为自动抢红包、切换账号、修改运动步数、修改定位的经纬度。


使用CaptainHook的方式下钩子。

自动抢红包、修改运动步数、修改定位的经纬度功能界面：
在设置界面中增加一个“微信小助手”的cell，通过这个入口进入插件界面，自动抢红包功能可以修改延迟的时间，使用队列的方式，防止连续多次抢红包，减少被系统检测到插件的可能。

切换账号界面：
通过在最近登录界面增加切换账号按钮，登录时缓存账号的方式，将缓存的账号显示到列表中，点击某个账号可以进行快速切换。<br>


![image](https://github.com/Musk66/WxAssistant/blob/master/01.png)
