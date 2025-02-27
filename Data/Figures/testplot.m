%% DDPG DE F 数据
data1 = [
    -29.48541, -136.063, -264.562;
    -43116.19, -3713869, -10388790;
    -133.583, -651.71, -1259.36;
    -188.597, -1401.64, -3150.8;
    0.65483, 81.322, 131.36;
    -53.96599, -229.6, -431.41;
    -96.54372, -579.738, -1423.27;
    -17120.56, -189594.9, -412155;
    -1878.35, -175237.4, -433009.9;
    -37585.9, -790790, -2847000;
    -129.444, -281.9, -350.09;
    -7855690, -148809000, -378598000;
    -779.73, -1616.63, -2076.8;
    -8.52144, -26.3014, -55.8973;
    -112.694, -610.36, -1157.19;
    -0.93, 0.764, -0.206;
    -3.106, -6.5309, -9.3058;
    -6.4589, -20.316, -39.407;
    -1.7616, -17.2608, -21.9706;
    -6295.6283, -87403.34, -192143.7;
    -2.521814, -56.1651, -62.536;
    -10.98764, -13.4101, -70.2549;
    -0.0921, 0.1363, 0.0146;
    -25006.609, -435176.33, -908621.47
];

%% DQN DE MS 数据
data2 = [
    0.16046889, 9.6054, 16.359;
    183.05, 49214, 266649;
    34.409, 224.42, 403.44;
    54.581, 340.33, 621.31;
    -12.00717, -27.78, -15.31;
    0.622999, 21.0241, 36.834;
    0.878011, 45.442, 109.617;
    51.8534, 3199.2, 9791.4;
    52.872, 2939.26, 7557.2;
    2107.217, 171038, 575781;
    13.35279, 120.431, 230.599;
    143801.2961, 13279800, 32181000;
    65.6594, 312.89, 337.05;
    0.1971594, 3.839, 4.3984;
    28.608, 127.07, 190.98;
    1.6562, 0.879, -0.046;
    1.749035, 3.42927, 3.4235;
    4.5178, 12.8325, 14.3667;
    1.5773, 2.4217, 1.967;
    1.3848, 160.5662, 2999.56;
    -0.405514, 6.3664, 10.1869;
    -0.37464, 2.0536, -12.0729;
    0.0478, 0.0342, -0.1671;
    25.4, 157.5, 208.39
];

%% 创建 figure 并设置布局
figure;
set(gcf, 'Position', [100, 100, 1200, 500]); % 设置 figure 窗口大小

% 左侧热力图 (DDPG DE F)
subplot(1, 2, 1); % 1 行 2 列，第 1 个图
h1 = heatmap(data1);
h1.Title = 'Performance difference of DDPG\_DE\_F';
h1.XDisplayLabels = {'D=10', 'D=30', 'D=50'};
h1.YDisplayLabels = {'BBOB\_F1', 'BBOB\_F2', 'BBOB\_F3', 'BBOB\_F4', 'BBOB\_F5', 'BBOB\_F6', 'BBOB\_F7', 'BBOB\_F8', 'BBOB\_F9', 'BBOB\_F10', 'BBOB\_F11', 'BBOB\_F12', 'BBOB\_F13', ...
    'BBOB\_F14', 'BBOB\_F15', 'BBOB\_F16', 'BBOB\_F17', 'BBOB\_F18', 'BBOB\_F19', 'BBOB\_F20', 'BBOB\_F21', 'BBOB\_F22', 'BBOB\_F23', 'BBOB\_F24'};
h1.ColorbarVisible = 'off'; % 不显示颜色条

% 右侧热力图 (DQN DE MS)
subplot(1, 2, 2); % 1 行 2 列，第 2 个图
h2 = heatmap(data2);
h2.Title = 'Performance difference of DQN\_DE\_MS';
h2.XDisplayLabels = {'D=10', 'D=30', 'D=50'};
h2.YDisplayLabels = {'BBOB\_F1', 'BBOB\_F2', 'BBOB\_F3', 'BBOB\_F4', 'BBOB\_F5', 'BBOB\_F6', 'BBOB\_F7', 'BBOB\_F8', 'BBOB\_F9', 'BBOB\_F10', 'BBOB\_F11', 'BBOB\_F12', 'BBOB\_F13', ...
    'BBOB\_F14', 'BBOB\_F15', 'BBOB\_F16', 'BBOB\_F17', 'BBOB\_F18', 'BBOB\_F19', 'BBOB\_F20', 'BBOB\_F21', 'BBOB\_F22', 'BBOB\_F23', 'BBOB\_F24'};
h2.ColorbarVisible = 'off'; % 不显示颜色条

% 添加共用颜色条
colorbar('Position', [0.92, 0.2, 0.02, 0.6]); % 设置颜色条位置