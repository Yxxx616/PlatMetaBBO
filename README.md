# PlatMetaBBO
**A Matlab platform for meta-black-box optimization, covering rl-assisted EA meta-learning.**
- *声明：非完全原创，基于platEMO平台*
- *建议：有platemo基础的同学食用更佳*

# V0.1
- GUI未包含训练过程，只能用于测试。

# Main function
platmetabbo.m

# Quick Start
1. 训练一个meta-optimier
- platmetabbo('task', @Train, 'metabboComps', 'DDPG_DE_F', 'problemSet','BBOB')
2. 测试训练好的meta-optimizer
- 使用预切分的测试集测试：platmetabbo('task', @Test, 'metabboComps', 'DDPG_DE_F', 'problemSet','BBOB')

# NOTE
1. 写自己的MetaBBO时需要先定义base-optimizer，思考参数化哪部分（学习base-optimizer的什么东西），然后设计metaoptimizer的输入也就是state，然后根据state的大小在Environment中定义observationInfo和actionInfo。
2. 训练的参数在Train.m中修改，测试的参数在Test.m中修改。训练集和测试集的切分在Utils下的splitProblemSet函数中修改。
3. 使用命令行测试时只可以测试一个算法，但是测试问题可以通过修改'problemSet'参数的值为'LIRCMOP'、'CF'等platEMO包含的任何测试问题集，只需要测试问题集的名字即可。
4. 测试时建议选择用GUI，直接运行platmetabbo.m，进入到GUI界面，选择test模块或exp模块，再选择自己训练好的meta-optimizer对应的base-optimizer，test可以测试单独函数，exp可以测试多个函数并且可以和任何platemo里想对比的算法进行对比试验！！不过需要在GUI的test或者exp文件中设置一下自己的meta-optimizer和environment哦。

# Conclusion
暂且先这样啦，后续再更新说明文档
# FIGHTING!

# PlatMetaBBO Copyright
Copyright (c) 2025 还没想好名字 Group. You are free to use the PlatMetaBBO for research purposes. All publications which use this platform or any code in the platform should acknowledge the use of "PlatMetaBBO" and reference "Xu Yang, and Rui Wang. PlatMetaBBO: A MATLAB platform for meta-black-box optimization [educational forum], *畅想一下TEVC, 2025, .(.): ..-..*".

# PlatEMO Copyright
Copyright (c) 2024 BIMK Group. You are free to use the PlatEMO for research purposes. All publications which use this platform or any code in the platform should acknowledge the use of "PlatEMO" and reference "Ye Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform for evolutionary multi-objective optimization [educational forum], IEEE Computational Intelligence Magazine, 2017, 12(4): 73-87".
