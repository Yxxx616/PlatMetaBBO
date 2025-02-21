# PlatMetaBBO
**A Matlab platform for meta-black-box optimization, covering rl-assisted EA meta-learning.**
- *声明：非完全原创，基于platEMO平台*
- *建议：有platemo基础的同学食用更佳*

# V0.1
- GUI还不完善奥，只能测试用（test和exp都可以，其余两个功能模块还未修改）

# Main function
platmetabbo.m

# Quick Start
1. 训练一个meta-optimier
- platmetabbo('task', @Train, 'metaOptimizer', @PPOCMO, 'baseOptimizer', @ppoNSGAII, 'env', @EPSILONCMOAADEnvironment, 'problemSet','LIRCMOP','N',100,'maxFE',20000,'D',10)
2. 测试训练好的meta-optimizer
- platmetabbo('task', @Test, 'metaOptimizer', @PPOCMO, 'baseOptimizer', @ppoNSGAII, 'env', @EPSILONCMOAADEnvironment, 'problemSet','LIRCMOP','N',100,'maxFE',20000,'D',10)

# NOTE
1. 训练时搭配的meta-optimizer和base-optimizer和环境在测试时要保持一致。
2. 训练的参数在Train.m中修改（包括训练集的具体问题设置），测试的参数在Test.m中修改（包括测试集的具体问题设置）。
3. 使用命令行测试时只可以测试一个算法，但是测试问题可以通过修改'problemSet'参数的值为'LIRCMOP'、'CF'等platEMO包含的任何测试问题集，只需要测试问题集的名字即可，具体该集合下的哪些测试问题需要在Test.m中修改。
4. 测试时建议选择用GUI，直接运行platmetabbo.m，进入到GUI界面，选择test模块或exp模块，再选择自己训练好的meta-optimizer对应的base-optimizer，test可以测试单独函数，exp可以测试多个函数并且可以和任何platemo里想对比的算法进行对比试验！！不过需要在GUI的test或者exp文件中设置一下自己的meta-optimizer和environment哦。

# Conclusion
暂且先这样啦，后续再更新说明文档
# FIGHTING!

# PlatMetaBBO Copyright
Copyright (c) 2025 还没想好名字 Group. You are free to use the PlatMetaBBO for research purposes. All publications which use this platform or any code in the platform should acknowledge the use of "PlatMetaBBO" and reference "Xu Yang, and Rui Wang. PlatMetaBBO: A MATLAB platform for meta-black-box optimization [educational forum], *畅想一下TEVC, 2025, .(.): ..-..*".

# PlatEMO Copyright
Copyright (c) 2024 BIMK Group. You are free to use the PlatEMO for research purposes. All publications which use this platform or any code in the platform should acknowledge the use of "PlatEMO" and reference "Ye Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform for evolutionary multi-objective optimization [educational forum], IEEE Computational Intelligence Magazine, 2017, 12(4): 73-87".
